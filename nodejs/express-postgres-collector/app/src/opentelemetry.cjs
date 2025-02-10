const os = require("os");
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { PeriodicExportingMetricReader, AggregationTemporality } = require("@opentelemetry/sdk-metrics");
const { Resource } = require("@opentelemetry/resources");
const {
  SemanticResourceAttributes,
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
const resource = new Resource({
  "appsignal.config.name": process.env.APPSIGNAL_APP_NAME,
  "appsignal.config.environment": process.env.NODE_ENV || "development",
  "appsignal.config.push_api_key": process.env.APPSIGNAL_PUSH_API_KEY,
  "appsignal.config.revision": "test-setups",
  "appsignal.config.language_integration": "node.js",
  "host.name": os.hostname(),
  // Customize the service name
  [SemanticResourceAttributes.SERVICE_NAME]: "Express server",
});

// Specify AppSignal collector location
const collectorHost = "http://appsignal-collector:8099"

// Custom metrics aggregation temporality selector
// This requires a patch because the Node.js exporter doesn't allow this to be
// specified per metric type.
const customAggregationTemporality = {
  COUNTER: AggregationTemporality.DELTA,
  UP_DOWN_COUNTER: AggregationTemporality.DELTA,
  OBSERVABLE_COUNTER: AggregationTemporality.DELTA,
  OBSERVABLE_GAUGE: AggregationTemporality.CUMULATIVE,
  OBSERVABLE_UP_DOWN_COUNTER: AggregationTemporality.DELTA,
  HISTOGRAM: AggregationTemporality.DELTA
}
class PatchedOTLPMetricExporter extends OTLPMetricExporter {
  selectAggregationTemporality(instrumentType) {
    const aggregationTemporality = customAggregationTemporality[instrumentType]
    return aggregationTemporality != undefined ? aggregationTemporality :
      super.selectAggregationTemporality(instrumentType);
  }
}
// Configure the OpenTelemetry HTTP exporter
const sdk = new NodeSDK({
  resource,
  traceExporter: new OTLPTraceExporter({
    url: `${collectorHost}/v1/traces`,
  }),
  metricReader: new PeriodicExportingMetricReader({
    exportIntervalMillis: 1000,
    exporter: new PatchedOTLPMetricExporter({
      url: `${collectorHost}/v1/metrics`,
    })
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});
sdk.start();
