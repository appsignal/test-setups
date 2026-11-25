<?php

use Appsignal\Appsignal;
use Appsignal\Integrations\Monolog\Handler as AppsignalLogHandler;
use Monolog\ErrorHandler;
use Monolog\Logger;
use OpenTelemetry\API\Trace\Span;
use OpenTelemetry\API\Trace\SpanKind;
use OpenTelemetry\API\Trace\StatusCode;

use function OpenTelemetry\Instrumentation\hook;

require_once __DIR__ . '/vendor/autoload.php';

$previousExceptionHandler = set_exception_handler(
    function (Throwable $error) use (&$previousExceptionHandler) {
        Appsignal::setError($error);

        if ($previousExceptionHandler) {
            $previousExceptionHandler($error);
            return;
        }

        throw $error;
    }
);

// WordPress has no logger of its own. Core and plugins log through PHP errors
// and `error_log()`, the same lines `WP_DEBUG_LOG` writes to `debug.log`.
$wordpressLogger = new Logger('wordpress', [AppsignalLogHandler::withLevel('debug')]);

// Only logs the error types `error_reporting()` allows, which WordPress sets
// from `WP_DEBUG`. PHP's own error handling still runs after it.
new ErrorHandler($wordpressLogger)
    ->registerErrorHandler()
    ->registerFatalHandler();

// `error_log()` is a native function, so no error handler sees its calls.
// The OpenTelemetry SDK reports its own export failures with `error_log()`,
// so the guard stops a failing export from logging itself in a loop.
hook(
    null,
    'error_log',
    pre: static function ($object, array $params) use ($wordpressLogger): void {
        static $logging = false;
        $message = $params[0] ?? null;
        if ($logging || !(is_scalar($message) || $message instanceof Stringable)) {
            return;
        }

        $logging = true;
        try {
            // Core only calls `error_log()` outside debug mode to report failures.
            $wordpressLogger->error((string) $message);
        } finally {
            $logging = false;
        }
    },
);

// Traces every `wp_remote_*()` call. The URL path and query are left out:
// Mailchimp's paths hold a hash of the subscriber's email. A stack, because a
// filter inside one request can make another.
$httpSpans = [];
hook(
    WP_Http::class,
    'request',
    pre: static function ($http, array $params) use (&$httpSpans): void {
        $method = strtoupper($params[1]['method'] ?? 'GET');
        $url = parse_url((string) $params[0]);
        $httpSpans[] = Appsignal::instrument($method, [
            'http.request.method' => $method,
            'server.address' => $url['host'] ?? null,
            'server.port' => $url['port'] ?? (($url['scheme'] ?? '') === 'https' ? 443 : 80),
            'url.scheme' => $url['scheme'] ?? null,
        ], SpanKind::KIND_CLIENT);
    },
    post: static function ($http, array $params, $response, ?Throwable $exception) use (&$httpSpans): void {
        $httpSpan = array_pop($httpSpans);
        if (!$httpSpan) {
            return;
        }

        $span = $httpSpan->getSpan();
        if (is_array($response)) {
            $span->setAttribute('http.response.status_code', $response['response']['code'] ?? null);
        }
        // HTTP error statuses are left to the caller: a 404 can be expected.
        if ($response instanceof WP_Error) {
            $span->setAttribute('error.type', $response->get_error_code());
            $span->setStatus(StatusCode::STATUS_ERROR, $response->get_error_message());
        }
        if ($exception) {
            $span->recordException($exception);
        }
        $httpSpan->end();
    },
);

function getRouteForWordpressRequest(): string
{
    global $wp;

    $requestPath = preg_replace('#(^|/)page/\d+$#', '', trim($wp->request ?? '', '/'));

    if (is_404()) {
        return '/{not-found}';
    }
    if (is_feed()) {
        return '/{feed}';
    }
    if (is_search()) {
        return '/?s={search}';
    }
    if (is_page()) {
        return '/' . get_page_uri(get_queried_object());
    }
    if (is_singular('post')) {
        $permalinkStructure = get_option('permalink_structure') ?: '/?p=%post_id%';
        return rtrim(preg_replace('/%(\w+)%/', '{$1}', $permalinkStructure), '/');
    }
    if (is_singular()) {
        return '/' . get_post_type() . '/{postname}';
    }
    if (is_category()) {
        return '/category/{category}';
    }
    if (is_tag()) {
        return '/tag/{tag}';
    }
    if (is_tax()) {
        return '/' . get_queried_object()->taxonomy . '/{term}';
    }
    if (is_author()) {
        return '/author/{author}';
    }
    if (is_date()) {
        return '/{date}';
    }
    if (is_post_type_archive()) {
        return '/' . $requestPath;
    }

    return '/' . $requestPath;
}

// REST route patterns like `/v2/posts/(?P<id>[\d]+)`.
// Replaces named groups with `{name}`.
function getRouteForRestPattern(string $pattern): string
{
    $namedGroups = preg_replace('#\(\?P<(\w+)>((?:[^()]|\((?2)\))*)\)#', '{$1}', $pattern);

    return '/' . rest_get_url_prefix() . $namedGroups;
}

// Matches the request to a route pattern.
// WordPress only passes the matched pattern to filters that are skipped when
// the permission check fails.
function getRouteForRestRequest(WP_REST_Server $server, WP_REST_Request $request): string
{
    foreach (array_keys($server->get_routes()) as $pattern) {
        if (preg_match('@^' . $pattern . '$@i', $request->get_route())) {
            return getRouteForRestPattern($pattern);
        }
    }

    return '/' . rest_get_url_prefix() . '/{not-found}';
}

// The normalized REST route request.
function getServedRestRoute(): ?string
{
    $route = $GLOBALS['wp']->query_vars['rest_route'] ?? null;
    if (!is_string($route)) {
        return null;
    }

    return untrailingslashit($route) ?: '/';
}

$requestSpan = null;

// WordPress is not loaded yet at this point, so `add_action()` doesn't exist,
// but it will pick up hooks that are in this global when it starts.
// `wp_loaded` runs for every request, including scripts like
// `wp-comments-post.php` and `wp-admin/admin-ajax.php`, which never render a
// template, so their route is the script path.
$GLOBALS['wp_filter']['wp_loaded'][1][] = [
    'accepted_args' => 0,
    'function' => function () use (&$requestSpan, $wordpressLogger) {
        $wordpressLogger->info(sprintf(
            'Started %s "%s"',
            $_SERVER['REQUEST_METHOD'] ?? 'GET',
            $_SERVER['REQUEST_URI'] ?? '/',
        ));
        $requestSpan = Span::getCurrent();
        $requestSpan->setAttribute('http.route', $_SERVER['SCRIPT_NAME'] ?? '/');
        $requestSpan->setAttribute('server.address', $_SERVER['SERVER_NAME'] ?? null);
        Appsignal::setNamespace('web');
        Appsignal::addTags(['custom' => 'tag']);
        Appsignal::addHeaders(getallheaders());
        if ($_POST) {
            Appsignal::setPayload($_POST);
        }
    },
];
$GLOBALS['wp_filter']['template_redirect'][1][] = [
    'accepted_args' => 0,
    'function' => function () use (&$requestSpan) {
        $requestSpan?->setAttribute('http.route', getRouteForWordpressRequest());
    },
];
// REST API requests are served before `template_redirect` runs. This filter
// also runs for REST requests WordPress makes internally, like the preloads on
// editor pages, so only the served request may set the route.
$GLOBALS['wp_filter']['rest_post_dispatch'][1][] = [
    'accepted_args' => 3,
    'function' => function ($response, $server, $request) use (&$requestSpan) {
        if ($request->get_route() === getServedRestRoute()) {
            $requestSpan?->setAttribute('http.route', getRouteForRestRequest($server, $request));
        }
        return $response;
    },
];

// this runs while the request span is still open.
register_shutdown_function(function () use (&$requestSpan) {
    $requestSpan?->setAttribute('http.response.status_code', http_response_code());
});

// The WordPress instrumentation ends the request span before the `shutdown`
// action runs, so the WP-Cron check queries there would each become their
// own trace. Group them in one trace, apart from the requests.
$shutdownSpan = null;
$GLOBALS['wp_filter']['shutdown'][PHP_INT_MIN][] = [
    'accepted_args' => 0,
    'function' => function () use (&$shutdownSpan) {
        $shutdownSpan = Appsignal::instrument(current_action());
        Appsignal::setNamespace('background');
    },
];
$GLOBALS['wp_filter']['shutdown'][PHP_INT_MAX][] = [
    'accepted_args' => 0,
    'function' => function () use (&$shutdownSpan) {
        $shutdownSpan?->end();
    },
];
