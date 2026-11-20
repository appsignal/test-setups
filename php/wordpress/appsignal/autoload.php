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

$requestSpan = null;

// WordPress is not loaded yet at this point, so `add_action()` doesn't exist,
// but it will pick up hooks that are in this global when it starts.
$GLOBALS['wp_filter']['template_redirect'][1][] = [
    'accepted_args' => 0,
    'function' => function () use (&$requestSpan) {
        $requestSpan = Span::getCurrent();
        $requestSpan->setAttribute('http.route', getRouteForWordpressRequest());
        $requestSpan->setAttribute('server.address', $_SERVER['SERVER_NAME'] ?? null);
        Appsignal::setNamespace('web');
        Appsignal::addTags(['custom' => 'tag']);
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
