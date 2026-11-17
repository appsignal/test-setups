<?php

use Appsignal\Appsignal;

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

function getActionPathForWordpressRequest(): string
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

// WordPress is not loaded yet at this point, so `add_action()` doesn't exist,
// but it will pick up hooks that are in this global when it starts.
$GLOBALS['wp_filter']['template_redirect'][1][] = [
    'accepted_args' => 0,
    'function' => function () {
        $requestMethod = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        Appsignal::setAction($requestMethod . ' ' . getActionPathForWordpressRequest());
    },
];
