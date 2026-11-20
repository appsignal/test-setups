<?php

use Appsignal\Appsignal;
use OpenTelemetry\API\Trace\Span;

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
    'function' => function () use (&$requestSpan) {
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
