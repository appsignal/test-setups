import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
import { BatchSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { DocumentLoadInstrumentation } from '@opentelemetry/instrumentation-document-load';
import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
import { BaseOpenTelemetryComponent } from '@opentelemetry/plugin-react-load';

export function initTelemetry() {
  // Initialize React Load plugin
  BaseOpenTelemetryComponent.setTracer('react-vite-frontend', '1.0.0');

  const provider = new WebTracerProvider({
    resource: new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: 'react-vite-frontend',
      'appsignal.config.name': import.meta.env.VITE_APPSIGNAL_APP_NAME,
      'appsignal.config.environment': import.meta.env.VITE_APPSIGNAL_APP_ENV,
      'appsignal.config.push_api_key': import.meta.env.VITE_APPSIGNAL_FRONTEND_PUSH_API_KEY,
      'appsignal.config.revision': 'abcd123',
      'appsignal.config.language_integration': 'typescript',
      'appsignal.config.app_path': import.meta.env.VITE_PWD,
      'host.name': import.meta.env.VITE_HOSTNAME,
    }),
  });

  const collectorOptions = {
    url: 'http://localhost:8099/v1/traces',
  };
  
  const exporter = new OTLPTraceExporter(collectorOptions);
  provider.addSpanProcessor(new BatchSpanProcessor(exporter));

  provider.register();

  registerInstrumentations({
    instrumentations: [
      new DocumentLoadInstrumentation(),
    ],
  });
}
