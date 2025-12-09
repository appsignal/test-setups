<?php

namespace AppSignal\AppSignalSymfony;

use OpenTelemetry\API\Trace\Propagation\TraceContextPropagator;
use OpenTelemetry\Contrib\Otlp\MetricExporter;
use OpenTelemetry\SDK\Logs\Processor\SimpleLogRecordProcessor;
use OpenTelemetry\SDK\Logs\LoggerProvider;
use OpenTelemetry\SDK\Metrics\MeterProvider;
use OpenTelemetry\Contrib\Otlp\LogsExporter;
use OpenTelemetry\SDK\Sdk;
use OpenTelemetry\SDK\Trace\Sampler\AlwaysOnSampler;
use OpenTelemetry\SDK\Trace\Sampler\ParentBased;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;
use OpenTelemetry\SDK\Metrics\MetricReader\ExportingReader;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Resource\ResourceInfo;
use OpenTelemetry\SDK\Resource\ResourceInfoFactory;
use Symfony\Component\Dotenv\Dotenv;

class AppSignal
{
	protected static bool $initialized = false;
	protected static ?string $basePath = null;

	public static function initialize(): void
	{
		if (static::$initialized) {
			return;
		}

		static::$basePath = static::findSymfonyRoot();

		if (is_null(static::$basePath)) {
			return;
		}

		static::loadEnv();

		static::initializedOpenTelemetry();
	}


	protected static function initializedOpenTelemetry(): void
	{
		$name = $_ENV['APPSIGNAL_APP_NAME'] ?? $_ENV['APP_NAME'];
		$environment = $_ENV['APP_ENV'] ?? 'local';
		$pushApiKey = $_ENV['APPSIGNAL_PUSH_API_KEY'];
		$collector = $_ENV['APPSIGNAL_COLLECTOR_URL'];

		if (!$pushApiKey || !$collector) return;

		$serviceName = "Symfony Service";

		$revision = static::getRevisionFromGit();

		$resource = ResourceInfoFactory::defaultResource()->merge(ResourceInfo::create(Attributes::create([
			'service.name' => $serviceName,
			'appsignal.config.name' => $name,
			'appsignal.config.environment' => $environment,
			'appsignal.config.push_api_key' => $pushApiKey,
			'appsignal.config.revision' => $revision,
			'appsignal.config.language_integration' => 'php',
			'appsignal.config.app_path' => __DIR__,
			'host.name' => gethostname(),
		])));

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

		static::$initialized = true;
	}

	protected static function loadEnv(): void
	{
		if (isset($_ENV['APP_KEY'])) return;

		if (is_null(static::$basePath)) return;

		$envPath = static::$basePath . '/.env';

		if (file_exists(filename: $envPath)) {
			$dotenv = new Dotenv();
			$dotenv->load(static::$basePath . '/.env');
		}
	}

	protected static function findSymfonyRoot(): ?string
	{
		foreach (get_included_files() as $file) {
			if (str_ends_with($file, '/vendor/autoload.php')) {
				$root = dirname($file, 2);

				if (
					file_exists($root . '/symfony.lock') &&
					file_exists($root . '/composer.json')
				) {
					return $root;
				}
			}
		}

		return null;
	}

	protected static function getRevisionFromGit(): string
	{
		if (is_null(static::$basePath)) return 'unknown';

		$command = sprintf(
			'git -C %s rev-parse HEAD 2>/dev/null',
			escapeshellarg(static::$basePath),
		);

		return trim(shell_exec($command) ?? 'unknown');
	}
}
