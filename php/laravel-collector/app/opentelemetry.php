<?php

use OpenTelemetry\API\Globals;
use OpenTelemetry\API\Logs\EventLogger;
use OpenTelemetry\API\Logs\LogRecord;
use OpenTelemetry\API\Trace\Propagation\TraceContextPropagator;
use OpenTelemetry\Contrib\Otlp\LogsExporter;
use OpenTelemetry\Contrib\Otlp\MetricExporter;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
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

require 'vendor/autoload.php';

$resource = ResourceInfoFactory::emptyResource()->merge(ResourceInfo::create(Attributes::create([
    ResourceAttributes::SERVICE_NAMESPACE => 'demo',
    ResourceAttributes::SERVICE_NAME => 'test-application',
    ResourceAttributes::SERVICE_VERSION => '0.1',
    "appsignal.config.name" => getenv("APPSIGNAL_APP_NAME"),
    "appsignal.config.environment" => getenv("APPSIGNAL_APP_ENV"),
    "appsignal.config.push_api_key" => getenv("APPSIGNAL_PUSH_API_KEY"),
    "appsignal.config.revision" => "test-setups",
    "appsignal.config.language_integration" => "php",
    "host.name" => gethostname(),
    # Customize the service name
    "service.name" => "Laravel server",
])));
$transport = (new OtlpHttpTransportFactory())->create('http://appsignal-collector:8099/v1/traces', 'application/x-protobuf');
$spanExporter = new SpanExporter($transport);
// $spanExporter = new SpanExporter((new StreamTransportFactory())->create('php://stdout', 'application/json'));

$reader = new ExportingReader(new MetricExporter($transport));
// $reader = new ExportingReader(new MetricExporter((new StreamTransportFactory())->create('php://stdout', 'application/json')));

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

Sdk::builder()
    ->setTracerProvider($tracerProvider)
    ->setMeterProvider($meterProvider)
    ->setPropagator(TraceContextPropagator::getInstance())
    ->setAutoShutdown(true)
    ->buildAndRegisterGlobal();
