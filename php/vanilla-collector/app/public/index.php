<?php

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../bootstrap/instrumentation.php';

use OpenTelemetry\API\Logs\LogRecord;
use OpenTelemetry\API\Trace\Span;
use OpenTelemetry\API\Trace\StatusCode;
use OpenTelemetry\API\Globals;
use OpenTelemetry\API\Logs\Severity;
use App\ErrorHandler;

$tracer = Globals::tracerProvider()->getTracer('vanilla-php-app');
$logger = Globals::loggerProvider()->getLogger('vanilla-php-app');

$span = $tracer->spanBuilder('request')
    ->startSpan();

try {
    $span->setAttribute('http.method', $_SERVER['REQUEST_METHOD']);
    $span->setAttribute('http.url', $_SERVER['REQUEST_URI']);

    $requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

    if ($requestUri === '/') {
        echo "<h1>Vanilla PHP App with OpenTelemetry</h1>";
        echo "<p>Welcome to the vanilla PHP app!</p>";
        echo "<p><a href='/error'>Test Error Handling</a></p>";
        echo "<p><a href='/slow'>Test Slow Request</a></p>";
    } elseif ($requestUri === '/slow') {
        echo "<h1>Slow Request</h1>";
        sleep(3);
        echo "<p>This request took 3 seconds to complete.</p>";
        echo "<p><a href='/'>Go back</a></p>";
    } elseif ($requestUri === '/error') {
        echo "<h1>Error Test</h1>";

        try {
            $errorHandler = new ErrorHandler();
            $errorHandler->throwError();
        } catch (\Exception $e) {
            // Report error to OpenTelemetry without crashing the app
            $span->recordException($e);
            $span->setStatus(StatusCode::STATUS_ERROR, $e->getMessage());

            // Also log the error
            $logRecord = (new LogRecord('Error occurred'))
                ->setSeverity(Severity::ERROR)
                ->setAttributes([
                    'exception.type' => get_class($e),
                    'exception.message' => $e->getMessage(),
                    'exception.stacktrace' => $e->getTraceAsString(),
                ]);
            $logger->emit($logRecord);

            echo "<p>An error occurred: " . htmlspecialchars($e->getMessage()) . "</p>";
            echo "<p>The error has been reported to AppSignal via OpenTelemetry.</p>";
            echo "<p><a href='/'>Go back</a></p>";
        }
    } else {
        http_response_code(404);
        echo "<h1>404 Not Found</h1>";
        echo "<p><a href='/'>Go back</a></p>";
    }
} catch (\Exception $e) {
    $span->recordException($e);
    $span->setStatus(StatusCode::STATUS_ERROR, $e->getMessage());

    echo "<h1>Unexpected Error</h1>";
    echo "<p>An unexpected error occurred.</p>";
} finally {
    $span->end();
}
