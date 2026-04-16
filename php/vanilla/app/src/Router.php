<?php

namespace App;

use Appsignal\Appsignal;
use Appsignal\Integrations\Monolog\Handler;
use Monolog\Logger;
use OpenTelemetry\API\Trace\SpanKind;

/**
 * Basic router that creates Laravel and Symfony-like root spans
 */
class Router
{
    public static function handle(string $method, string $uri): void
    {
        $span = Appsignal::instrument("$method $uri", spanKind: SpanKind::KIND_SERVER, attributes: ['http.request.method' => $method, 'http.route' => $uri]);

        try {
            static::route($uri);
            $span->setAttribute('http.response.status_code', 200);
        } catch (\Throwable $e) {
            Appsignal::setError($e);
            $span->setAttribute('http.response.status_code', 500);
            View::renderError($e);
        } finally {
            $span->end();
        }
    }

    // handles only get requests
    protected static function route(string $uri): void
    {
        $logger = new Logger('app');
        $logger->pushHandler(Handler::withLevel('info'));

        match ($uri) {
            '/' => View::index(),
            '/slow' => (function () {
                sleep(3);
                View::render('Slept for 3 seconds.');
            })(),
            '/instrument' => (function () {
                Appsignal::instrument(
                    'my-span',
                    [
                        'string-attribute' => 'abcdef',
                        'int-attribute' => 1234,
                        'bool-attribute' => true,
                    ],
                    closure: fn() => null,
                );
                View::render('Added a span to this trace.');
            })(),
            '/instrument-nested' => (function () {
                Appsignal::instrument('parent', ['msg' => 'from parent span'], closure: function () {
                    $span = Appsignal::instrument('child', ['msg' => 'from child span']);
                    $span->end();
                });
                View::render('Added nested spans to this trace.');
            })(),
            '/set-action' => (function () {
                Appsignal::setAction('my action');
                View::render('Set custom action name for this trace.');
            })(),
            '/custom-data' => (function () {
                Appsignal::addAttributes([
                    'string-attribute' => 'abcdef',
                    'int-attribute' => 1234,
                    'bool-attribute' => true,
                ]);
                View::render('Set custom data for this trace.');
            })(),
            '/tags' => (function () {
                Appsignal::addTags([
                    'string-tag' => 'some value',
                    'integer-tag' => 1234,
                    'bool-tag' => true,
                ]);
                View::render('Added tags to this trace.');
            })(),
            '/log' => (function () use ($logger) {
                $logger->info('My log');
                View::render('Sent a log.');
            })(),
            '/log-with-attributes' => (function () use ($logger) {
                $logger->info('My log with attributes', ['foo' => 'bar']);
                View::render('Sent a log with attributes.');
            })(),
            '/set-gauge' => (function () {
                Appsignal::setGauge('my_gauge', 12);
                Appsignal::setGauge('my_gauge_with_attributes', 13, ['region' => 'eu']);
                View::render('Set a gauge with and without attributes.');
            })(),
            '/add-distribution-value' => (function () {
                Appsignal::addDistributionValue('my_distribution', 50);
                Appsignal::addDistributionValue('my_distribution', 70);
                Appsignal::addDistributionValue('my_distribution_with_attributes', 10, ['region' => 'eu']);
                Appsignal::addDistributionValue('my_distribution_with_attributes', 20, ['region' => 'eu']);
                Appsignal::addDistributionValue('my_distribution_with_attributes', 30, ['region' => 'eu']);
                View::render('Added values to a distribution with and without attributes.');
            })(),
            '/counter' => (function () {
                Appsignal::incrementCounter('my_counter', 1);
                Appsignal::incrementCounter('my_counter', 3, ['region' => 'eu']);
                View::render('Incremented counter with and without attributes.');
            })(),
            '/error' => (function () {
                $controller = new ErrorsController();
                $controller->show();
            })(),
            '/error-wrapped' => (function () {
                $controller = new ErrorsController();
                $controller->wrapped();
            })(),
            default => throw new NotFoundException("Not found: $uri"),
        };
    }
}

class NotFoundException extends \Exception {}
