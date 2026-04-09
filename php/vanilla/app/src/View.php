<?php

namespace App;

class View
{
    public static function render(string $message, ?array $json = null): void
    {
        echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Vanilla PHP</title>
</head>
<body>
    <p>' . htmlspecialchars($message) . '</p>';

        if ($json !== null) {
            echo '<pre>' . htmlspecialchars(json_encode($json, JSON_PRETTY_PRINT)) . '</pre>';
        }

        echo '
    <p><a href="/">← Back to Home</a></p>
</body>
</html>';
    }

    public static function renderError(\Throwable $e): void
    {
        http_response_code(500);
        echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Error - Vanilla PHP</title>
</head>
<body>
    <h1>Error</h1>
    <p><strong>' . htmlspecialchars($e->getMessage()) . '</strong></p>
    <h2>Backtrace</h2>
    <pre>' . htmlspecialchars($e->getTraceAsString()) . '</pre>
    <p><a href="/">← Back to Home</a></p>
</body>
</html>';
    }

    public static function index(): void
    {
        echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Vanilla PHP</title>
</head>
<body>
    <h1>Appsignal PHP + Vanilla</h1>

    <h2>Errors:</h2>
    <ul>
        <li><a href="/error">/error</a></li>
        <li><a href="/error-wrapped">/error-wrapped</a></li>
    </ul>

    <h2>Instrumentation:</h2>
    <ul>
        <li><a href="/instrument">/instrument</a></li>
        <li><a href="/instrument-nested">/instrument-nested</a></li>
        <li><a href="/set-action">/set-action</a></li>
        <li><a href="/custom-data">/custom-data</a></li>
        <li><a href="/tags">/tags</a></li>
    </ul>

    <h2>Metrics:</h2>
    <ul>
        <li><a href="/set-gauge">/set-gauge</a></li>
        <li><a href="/add-distribution-values">/add-distribution-values</a></li>
        <li><a href="/counter">/counter</a></li>
    </ul>

    <h2>Logs:</h2>
    <ul>
        <li><a href="/log">/log</a></li>
        <li><a href="/log-with-attributes">/log-with-attributes</a></li>
    </ul>

    <h2>Other features:</h2>
    <ul>
        <li><a href="/slow">/slow</a></li>
    </ul>
</body>
</html>';
    }
}
