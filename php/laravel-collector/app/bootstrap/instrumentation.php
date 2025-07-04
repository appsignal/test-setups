<?php

use OpenTelemetry\API\Globals;
use OpenTelemetry\API\Logs\EventLogger;
use OpenTelemetry\API\Logs\LogRecord;
use OpenTelemetry\API\Trace\Propagation\TraceContextPropagator;
use OpenTelemetry\Contrib\Otlp\LogsExporter;
use OpenTelemetry\Contrib\Otlp\MetricExporter;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Common\Export\Stream\StreamTransportFactory;
use OpenTelemetry\SDK\Logs\LoggerProvider;
use OpenTelemetry\SDK\Logs\Processor\SimpleLogRecordProcessor;
use OpenTelemetry\SDK\Metrics\MeterProvider;
use OpenTelemetry\SDK\Metrics\MetricReader\ExportingReader;
use OpenTelemetry\SDK\Resource\ResourceInfo;
use OpenTelemetry\SDK\Resource\ResourceInfoFactory;
use OpenTelemetry\SDK\Sdk;
use OpenTelemetry\SDK\Trace\Sampler\AlwaysOnSampler;
use OpenTelemetry\SDK\Trace\Sampler\ParentBased;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;
use OpenTelemetry\SemConv\ResourceAttributes;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;

$resource = ResourceInfoFactory::emptyResource()->merge(ResourceInfo::create(Attributes::create([
  'service.name' => "Laravel",
  'appsignal.config.name' => $_ENV['APPSIGNAL_APP_NAME'],
  'appsignal.config.environment' => $_ENV['APPSIGNAL_APP_ENV'],
  'appsignal.config.push_api_key' => $_ENV['APPSIGNAL_PUSH_API_KEY'],
  'appsignal.config.revision' => 'abcd123',
  'appsignal.config.language_integration' => 'php',
  'appsignal.config.app_path' => dirname(__DIR__),
  'host.name' => gethostname(),
  'test_value' => $_ENV['TEST_VALUE'] ?? 'default_value',
])));

$collector = 'http://appsignal-collector:8099';


$spanExporter = new SpanExporter(
    (new OtlpHttpTransportFactory())->create("$collector/v1/traces", 'application/x-protobuf')
);

$logExporter = new LogsExporter(
    (new OtlpHttpTransportFactory())->create("$collector/v1/logs", 'application/x-protobuf')
);

$reader = new ExportingReader(
    new MetricExporter(
        (new OtlpHttpTransportFactory())->create("$collector/v1/metrics", 'application/x-protobuf')
    )
);

$meterProvider = MeterProvider::builder()
    ->setResource($resource)
    ->addReader($reader)
    ->build();

$tracerProvider = TracerProvider::builder()
    ->addSpanProcessor(
        new SimpleSpanProcessor($spanExporter)
    )
    ->setResource($resource)
    ->setSampler(new ParentBased(new AlwaysOnSampler()))
    ->build();

$loggerProvider = LoggerProvider::builder()
    ->setResource($resource)
    ->addLogRecordProcessor(
        new SimpleLogRecordProcessor($logExporter)
    )
    ->build();

Sdk::builder()
    ->setTracerProvider($tracerProvider)
    ->setMeterProvider($meterProvider)
    ->setLoggerProvider($loggerProvider)
    ->setPropagator(TraceContextPropagator::getInstance())
    ->setAutoShutdown(true)
    ->buildAndRegisterGlobal();
