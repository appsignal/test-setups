import { registerOTel } from "@vercel/otel";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-proto";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-proto";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";

const collectorHost = "http://appsignal-collector:8099";

export function register() {
  registerOTel({
    serviceName: "Next.js app",
    traceExporter: new OTLPTraceExporter({
      url: `${collectorHost}/v1/traces`,
    }),
    metricReader: new PeriodicExportingMetricReader({
      exportIntervalMillis: 1000,
      exporter: new OTLPMetricExporter({
        url: `${collectorHost}/v1/metrics`,
      }),
    }),
    attributes: {
      "appsignal.config.name": process.env.APPSIGNAL_APP_NAME,
      "appsignal.config.environment": process.env.NODE_ENV,
      "appsignal.config.revision": "test-setups",
      "appsignal.config.language_integration": "nodejs",
      "appsignal.config.push_api_key": process.env.APPSIGNAL_PUSH_API_KEY,
      "host.name": "test-container",
    },
  });
}
