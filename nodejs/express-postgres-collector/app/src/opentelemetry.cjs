const os = require("os");
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { PeriodicExportingMetricReader } = require("@opentelemetry/sdk-metrics");
const { resourceFromAttributes } = require("@opentelemetry/resources");
const {
  ATTR_SERVICE_NAME,
} = require("@opentelemetry/semantic-conventions");
const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-proto");
const {
  OTLPMetricExporter,
} = require("@opentelemetry/exporter-metrics-otlp-proto");
const {
  getNodeAutoInstrumentations
} = require("@opentelemetry/auto-instrumentations-node");

// Add AppSignal and app configuration
const resource = resourceFromAttributes({
  "appsignal.config.name": process.env.APPSIGNAL_APP_NAME,
  "appsignal.config.environment": process.env.NODE_ENV || "development",
  "appsignal.config.push_api_key": process.env.APPSIGNAL_PUSH_API_KEY,
  "appsignal.config.revision": "test-setups",
  "appsignal.config.language_integration": "node.js",
  "appsignal.config.app_path": process.cwd(),
  "appsignal.config.filter_request_parameters": [
    "password",
    "email",
    "cvv"
  ],
  "appsignal.config.filter_request_session_data": [
    "token",
  ],
  "appsignal.config.filter_function_parameters": [
    "hash",
    "salt",
  ],
  "host.name": os.hostname(),
  // Customize the service name
  [ATTR_SERVICE_NAME]: "Express server",
});

// Specify AppSignal collector location
const collectorHost = "http://appsignal-collector:8099"

// Configure the OpenTelemetry HTTP exporter
const sdk = new NodeSDK({
  resource,
  traceExporter: new OTLPTraceExporter({
    url: `${collectorHost}/v1/traces`,
  }),
  metricReader: new PeriodicExportingMetricReader({
    exportIntervalMillis: 1000,
    exporter: new OTLPMetricExporter({
      url: `${collectorHost}/v1/metrics`,
    })
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});
sdk.start();
