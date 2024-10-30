import { WebTracerProvider } from "@opentelemetry/sdk-trace-web";
import { Resource } from "@opentelemetry/resources";
import { SemanticResourceAttributes } from "@opentelemetry/semantic-conventions";
import { ZoneContextManager } from "@opentelemetry/context-zone";
import { BatchSpanProcessor, SimpleSpanProcessor, ConsoleSpanExporter } from "@opentelemetry/sdk-trace-base";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-proto";
import { registerInstrumentations } from "@opentelemetry/instrumentation";
import { XMLHttpRequestInstrumentation } from "@opentelemetry/instrumentation-xml-http-request";
import { FetchInstrumentation } from "@opentelemetry/instrumentation-fetch";
import { UserInteractionInstrumentation } from "@opentelemetry/instrumentation-user-interaction";
import { DocumentLoadInstrumentation } from "@opentelemetry/instrumentation-document-load";
import { LongTaskInstrumentation } from "@opentelemetry/instrumentation-long-task";
import * as api from "@opentelemetry/api";

export const initializeTracing = () => {
  api.diag.setLogger(
    new api.DiagConsoleLogger(),
    api.DiagLogLevel.ALL,
  );

  const provider = new WebTracerProvider({
    resource: new Resource({
      "appsignal.config.revision": "24-11-05",
      "appsignal.config.app_name": "javascript/react-otel",
      "appsignal.config.app_environment": "development",
      "appsignal.config.push_api_key": "",
      "appsignal.config.language_integration": "javascript",
      [SemanticResourceAttributes.SERVICE_NAME]: "javascript-react-otel",
    }),
  });

  // Register all common web instrumentations at once
  registerInstrumentations({
    instrumentations: [
      new XMLHttpRequestInstrumentation({
        propagateTraceHeaderCorsUrls: /.*/,
        debugWrappers: true,
      }),
      new FetchInstrumentation({
        propagateTraceHeaderCorsUrls: /.*/,
        debugWrappers: true,
      }),
      new UserInteractionInstrumentation(),
      new DocumentLoadInstrumentation(),
      new LongTaskInstrumentation(),
    ],
  });

  const collector = new OTLPTraceExporter({
    url: "http://localhost:3030/http://appsignal-agent:8099/enriched/v1/traces",
  });

  const consoleExporter = new ConsoleSpanExporter();

  provider.addSpanProcessor(new BatchSpanProcessor(collector));
  provider.addSpanProcessor(new SimpleSpanProcessor(consoleExporter));
  provider.register({ contextManager: new ZoneContextManager() });

  return provider.getTracer("react-tracer");
};
