const execSync = require('child_process').execSync;
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { trace } = require('@opentelemetry/api');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

// Get the Git revision using execSync and ensure it's a string
// const revision = execSync('git rev-parse --short HEAD').toString().trim();

// Add AppSignal and app configuration
const resource = new Resource({
  'appsignal.config.app_name': process.env["APPSIGNAL_APP_NAME"],
  'appsignal.config.app_environment': process.env["APPSIGNAL_APP_ENV"],
  'appsignal.config.push_api_key': process.env["APPSIGNAL_PUSH_API_KEY"],
  // 'appsignal.config.revision': revision,
  'appsignal.config.language_integration': 'node.js',
  'appsignal.config.app_path': process.cwd(),
  // Customize the service name
  [SemanticResourceAttributes.SERVICE_NAME]: 'Next.js server',
});

// Configure the OpenTelemetry HTTP exporter
const exporter = new OTLPTraceExporter({
  url: 'http://appsignal-agent:8099/enriched/v1/traces',
});

const sdk = new NodeSDK({
  resource,
  traceExporter: exporter,
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
