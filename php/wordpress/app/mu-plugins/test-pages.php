<?php

/**
 * Plugin Name: Test pages
 * Description: Adds the /slow and /error pages used to test AppSignal.
 */

const TEST_PAGES = [
    'slow' => 'Slow request',
    'error' => 'Error request',
];

// Logs the ways WordPress core and plugins do
function writeWordPressLogs(): void
{
    error_log('Logging from WordPress with error_log()');
    trigger_error('Warning from WordPress', E_USER_WARNING);
}

add_action('init', function () {
    $pageNames = implode('|', array_keys(TEST_PAGES));
    add_rewrite_rule("^($pageNames)/?$", 'index.php?test_page=$matches[1]', 'top');
});

add_filter('query_vars', function ($queryVars) {
    $queryVars[] = 'test_page';
    return $queryVars;
});

add_filter('template_include', function ($template) {
    if (get_query_var('test_page') === 'slow') {
        sleep(3);
        return __DIR__ . '/views/slow.php';
    }

    return $template;
});

// Thrown from the template step on purpose: the WordPress instrumentation
// doesn't track it, so this only gets reported by a global error handler.
add_filter('template_include', function ($template) {
    if (get_query_var('test_page') === 'error') {
        writeWordPressLogs();
        throw new Exception('Expected test error');
    }

    return $template;
});

// Stop WordPress from redirecting /slow to /slow/ before the page is shown
add_filter('redirect_canonical', function ($redirectUrl) {
    return get_query_var('test_page') ? false : $redirectUrl;
});

// Show links to the test pages at the top of the homepage
add_action('wp_body_open', function () {
    // WordPress treats a URL with only a custom parameter as the homepage
    if (!is_front_page() || get_query_var('test_page')) {
        return;
    }

    require __DIR__ . '/views/test-page-links.php';
});

// Fails while the content of the "error-post" post is rendered, like a broken
// plugin would. Matched by slug, because the post's id differs per install.
// `is_single()` keeps the homepage working, where the post is only listed.
add_filter('the_content', function ($content) {
    if (is_single('error-post')) {
        writeWordPressLogs();
        throw new Exception('Expected test error in a post');
    }

    return $content;
});
