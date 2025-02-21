package io.opentelemetry.example.graal;

import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.contrib.sampler.RuleBasedRoutingSampler;
import io.opentelemetry.exporter.otlp.http.trace.OtlpHttpSpanExporter;
import io.opentelemetry.sdk.autoconfigure.spi.AutoConfigurationCustomizerProvider;
import io.opentelemetry.sdk.autoconfigure.spi.ConfigProperties;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.export.SpanExporter;
import io.opentelemetry.sdk.trace.data.SpanData;
import io.opentelemetry.sdk.trace.samplers.Sampler;
import io.opentelemetry.semconv.ResourceAttributes;
import io.opentelemetry.semconv.UrlAttributes;
import java.util.Collections;
import java.util.Map;
import java.util.Collection;
import io.opentelemetry.sdk.common.CompletableResultCode;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.sdk.metrics.Aggregation;
import io.opentelemetry.sdk.metrics.InstrumentType;
import io.opentelemetry.sdk.metrics.data.AggregationTemporality;
import io.opentelemetry.sdk.metrics.export.DefaultAggregationSelector;
import io.opentelemetry.sdk.metrics.export.MetricReader;
import io.opentelemetry.sdk.metrics.export.PeriodicMetricReader;
import io.opentelemetry.exporter.otlp.http.metrics.OtlpHttpMetricExporter;  // Updated import
import io.opentelemetry.sdk.metrics.export.MetricExporter;
import io.opentelemetry.sdk.trace.export.SimpleSpanProcessor;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import java.util.Arrays;

@Configuration
public class OpenTelemetryConfig {

  @Bean
  public AutoConfigurationCustomizerProvider otelCustomizer() {
    return p ->
        p.addSpanExporterCustomizer(this::configureSpanExporter)
            .addResourceCustomizer(this::configureResource)
            .addMetricExporterCustomizer(this::configureMetricExporter);
  }

  private SpanExporter configureSpanExporter(SpanExporter exporter, ConfigProperties config) {
    if (exporter instanceof OtlpHttpSpanExporter) {
      SpanExporter otlpExporter = OtlpHttpSpanExporter.builder()
          .setEndpoint("http://appsignal-collector:8099/v1/traces")
          .build();
      
      SpanExporter consoleExporter = new SpanExporter() {
        @Override
        public CompletableResultCode export(Collection<SpanData> spans) {
          spans.forEach(span -> System.out.println("[Span] " + span));
          return CompletableResultCode.ofSuccess();
        }

        @Override
        public CompletableResultCode flush() {
          return CompletableResultCode.ofSuccess();
        }

        @Override
        public CompletableResultCode shutdown() {
          return CompletableResultCode.ofSuccess();
        }
      };
      
      return SpanExporter.composite(Arrays.asList(otlpExporter, consoleExporter));
    }
    
    return exporter;
  }

  private Resource configureResource(Resource resource, ConfigProperties config) {
    String hostname;
    try {
      hostname = java.net.InetAddress.getLocalHost().getHostName();
    } catch (Exception e) {
      hostname = "unknown";
    }

    return resource.merge(
        Resource.create(Attributes.builder()
            .put(AttributeKey.stringKey("appsignal.config.name"), System.getenv("APPSIGNAL_APP_NAME"))
            .put(AttributeKey.stringKey("appsignal.config.environment"), System.getenv("APPSIGNAL_APP_ENV"))
            .put(AttributeKey.stringKey("appsignal.config.push_api_key"), System.getenv("APPSIGNAL_PUSH_API_KEY"))
            .put(AttributeKey.stringKey("appsignal.config.revision"), "abcd123")
            .put(AttributeKey.stringKey("appsignal.config.language_integration"), "java")
            .put(AttributeKey.stringKey("appsignal.config.app_path"), System.getenv("PWD"))
            .put(AttributeKey.stringKey("service.name"), "Spring")
            .put(AttributeKey.stringKey("host.name"), hostname)
            .build()));
  }

  private MetricExporter configureMetricExporter(MetricExporter exporter, ConfigProperties config) {
    if (exporter instanceof OtlpHttpMetricExporter) {
      return OtlpHttpMetricExporter.builder()
          .setEndpoint("http://appsignal-collector:8099/v1/metrics")
          .build();
    }
    return exporter;
  }
}
