package io.opentelemetry.example.graal;

import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.contrib.sampler.RuleBasedRoutingSampler;
import io.opentelemetry.exporter.otlp.http.trace.OtlpHttpSpanExporter;
import io.opentelemetry.sdk.autoconfigure.spi.AutoConfigurationCustomizerProvider;
import io.opentelemetry.sdk.autoconfigure.spi.ConfigProperties;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.export.SpanExporter;
import io.opentelemetry.sdk.trace.samplers.Sampler;
import io.opentelemetry.semconv.ResourceAttributes;
import io.opentelemetry.semconv.UrlAttributes;
import java.util.Collections;
import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;

@Configuration
public class OpenTelemetryConfig {

  @Bean
  public AutoConfigurationCustomizerProvider otelCustomizer() {
    return p ->
        p.addSamplerCustomizer(this::configureSampler)
            .addSpanExporterCustomizer(this::configureSpanExporter)
            .addResourceCustomizer(this::configureResource);
  }

  /** suppress spans for actuator endpoints */
  private RuleBasedRoutingSampler configureSampler(Sampler fallback, ConfigProperties config) {
    return RuleBasedRoutingSampler.builder(SpanKind.SERVER, fallback)
        .drop(UrlAttributes.URL_PATH, "^/actuator")
        .build();
  }

  /**
   * Configuration for the OTLP exporter. This configuration will replace the default OTLP exporter,
   * and will add a custom header to the requests.
   */
  private SpanExporter configureSpanExporter(SpanExporter exporter, ConfigProperties config) {
    if (exporter instanceof OtlpHttpSpanExporter) {
      return ((OtlpHttpSpanExporter) exporter).toBuilder().setHeaders(this::headers).build();
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

  private Map<String, String> headers() {
    return Collections.singletonMap("Authorization", "Bearer " + refreshToken());
  }

  private String refreshToken() {
    // e.g. read the token from a kubernetes secret
    return "token";
  }
}
