<?php

namespace App\Controller;

use OpenTelemetry\API\Trace\Span;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use OpenTelemetry\API\Globals;
use OpenTelemetry\API\Logs\LogRecord;
use OpenTelemetry\API\Logs\Severity;
use Monolog\Logger;
use OpenTelemetry\Contrib\Logs\Monolog\Handler as OpenTelemetryHandler;

class HomeController extends AbstractController
{
    public function index(): Response
    {
        return $this->render('home/index.html.twig', [
            'message' => 'Welcome to Symfony with AppSignal!',
        ]);
    }

    public function slow(): Response
    {
        sleep(3);
        return $this->render('home/slow.html.twig');
    }

    public function error(Request $request): Response
    {
        if ($request->query->get('debug') == "true") {
            try {
                throwException();
            } catch (\Exception $e) {
                return $this->render('backtrace.html.twig', [
                    'error' => $e->getMessage(),
                    'backtrace' => $e->getTraceAsString()
                ], new Response('', 500));
            }
        } else {
            throwException();
        }
    }

    public function error_cause(Request $request): Response
    {
        if ($request->query->get('debug') == "true") {
            try {
                throwWrappedException();
            } catch (\Exception $e) {
                return $this->render('backtrace.html.twig', [
                    'error' => $e->getMessage(),
                    'backtrace' => $e->getTraceAsString()
                ], new Response('', 500));
            }
        } else {
            throwWrappedException();
        }
    }

    public function logs(): Response
    {
        // Stand-alone OpenTelemetry logging
        $loggerProvider = Globals::loggerProvider();
        $otelLogger = $loggerProvider->getLogger('my-app');

        // Log a message using OpenTelemetry directly
        $otelLogger->emit(
            (new LogRecord('Log message line'))
                ->setSeverityNumber(Severity::INFO)
        );

        // Log with attributes
        $otelLogger->emit(
            (new LogRecord('Generating invoice for customer'))
                ->setSeverityNumber(Severity::INFO)
                ->setAttributes(['customer_id' => 'cust_123'])
        );

        // Additional OpenTelemetry logging with attributes
        $otelLogger->emit(
            (new LogRecord('Log message using OpenTelemetry interface'))
                ->setSeverityNumber(Severity::INFO)
        );
        $otelLogger->emit(
            (new LogRecord('Something might be wrong'))
                ->setSeverityNumber(Severity::WARN)
        );
        $otelLogger->emit(
            (new LogRecord('An error occurred'))
                ->setSeverityNumber(Severity::ERROR)
                ->setAttributes(['error_code' => 500])
        );

        // Monolog with OpenTelemetry handler
        $loggerProvider = Globals::loggerProvider();
        $handler = new OpenTelemetryHandler($loggerProvider, 'info', true);
        $logger = new Logger('app', [$handler]);

        $logger->info('Log message with context - Monolog with OpenTelemetry handler', ['user_id' => 123]);
        $logger->warning('Something might be wrong - Monolog with OpenTelemetry handler');
        $logger->error('An error occurred - Monolog with OpenTelemetry handler', ['error_code' => 500]);

        return new Response('Logs were sent!');
    }

    public function metrics(): Response
    {
        // Get the meter from the global meter provider
        $meterProvider = Globals::meterProvider();
        $meter = $meterProvider->getMeter('my-app');

        // Counter metric
        $counter = $meter->createCounter('my_counter');
        $counter->add(1);
        $counter->add(1);

        // Gauge metric
        $gauge = $meter->createGauge('my_gauge');
        $gauge->record(100);
        $gauge->record(10);

        // Histogram metric for distributions (measurements)
        $histogram = $meter->createHistogram('my_histogram');
        $histogram->record(100);
        $histogram->record(110);

        // Metrics with attributes (tags)
        $counter = $meter->createCounter('my_tagged_counter');
        $counter->add(1, ['region' => 'eu']);
        $gauge = $meter->createGauge('my_tagged_gauge');
        $gauge->record(200, ['region' => 'asia']);
        $histogram = $meter->createHistogram('my_tagged_histogram');
        $histogram->record(150, ['region' => 'us']);

        return new Response('Metrics were sent!');
    }
}

class WrappedException extends \Exception {
     function __construct(string $message, $code, \Throwable $exception) {
             parent::__construct($message, $code, $exception);
     }
}

function throwWrappedException() {
    try {
        throwException();
    } catch(\Exception $e) {
        // chaining exception
        throw new WrappedException("I am a wrapped error", 0, $e);
    }
}

function throwException() {
    throw new \Exception('Uh oh!');
}
