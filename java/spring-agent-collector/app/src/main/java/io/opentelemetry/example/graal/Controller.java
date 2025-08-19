package io.opentelemetry.example.graal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import java.util.HashMap;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.message.ObjectMessage;
import org.apache.logging.log4j.message.MapMessage;
import org.apache.logging.log4j.message.StructuredDataMessage;
import org.apache.logging.log4j.ThreadContext;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.logging.Level;

import io.opentelemetry.api.metrics.DoubleGauge;
import io.opentelemetry.api.metrics.DoubleHistogram;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.Meter;

@RestController
public class Controller {

  @Autowired
  private ElasticsearchService elasticsearchService;

  private void setSpanAttributes() {
    Span span = Span.current();
    span.setAttribute("appsignal.tag.user_id", 123);
    span.setAttribute("appsignal.tag.my_tag_string", "tag value");
    span.setAttribute(AttributeKey.stringArrayKey("appsignal.tag.my_tag_string_array"), Arrays.asList("abc", "def"));
    span.setAttribute("appsignal.tag.my_tag_bool_true", true);
    span.setAttribute("appsignal.tag.my_tag_bool_false", false);
    span.setAttribute(AttributeKey.booleanArrayKey("appsignal.tag.my_tag_bool_array"), Arrays.asList(true, false));
    span.setAttribute("appsignal.tag.my_tag_float64", 12.34);
    span.setAttribute(AttributeKey.doubleArrayKey("appsignal.tag.my_tag_float64_array"), Arrays.asList(12.34, 56.78));
    span.setAttribute("appsignal.tag.my_tag_int", 1234);
    span.setAttribute(AttributeKey.longArrayKey("appsignal.tag.my_tag_int_array"), Arrays.asList(1234L, 5678L));
    span.setAttribute("appsignal.tag.my_tag_int64", 1234);
    span.setAttribute(AttributeKey.longArrayKey("appsignal.tag.my_tag_int64_array"), Arrays.asList(1234L, 5678L));

    // Create nested HashMap structure and serialize to JSON
    Map<String, Object> queryParams = new HashMap<>();
    queryParams.put("param1", "value1");
    queryParams.put("param2", "value2");

    Map<String, String> nested = new HashMap<>();
    nested.put("param3", "value3");
    nested.put("param4", "value4");
    queryParams.put("nested", nested);

    try {
      ObjectMapper mapper = new ObjectMapper();
      String jsonString = mapper.writeValueAsString(queryParams);
      span.setAttribute("appsignal.request.query_parameters", jsonString);
      span.setAttribute("appsignal.request.payload", jsonString);
      span.setAttribute("appsignal.request.session_data", jsonString);
      span.setAttribute("appsignal.function.parameters", jsonString);
    } catch (Exception e) {
      Logger logger = LogManager.getLogger(Controller.class);
      logger.error("Failed to serialize query parameters to JSON", e);
    }

    // Set single header values
    span.setAttribute("http.request.header.content-length", 123);
    span.setAttribute("http.request.header.request-method", "GET");
    span.setAttribute("http.request.header.path-info", "/some-path");
    span.setAttribute("http.request.header.content-type", "application/json");

    // Set header with multiple values (array)
    span.setAttribute(
      AttributeKey.stringArrayKey("http.request.header.custom-header"),
      Arrays.asList("value1", "value2")
    );
  }

  @GetMapping("/slow")
  public String slow() throws InterruptedException {
    setSpanAttributes();
    Thread.sleep(3000);
    return "Well, that took forever!";
  }

  @GetMapping("/error")
  public String error() {
    setSpanAttributes();
    throw new RuntimeException("Random error!");
  }

  @GetMapping("/error_with_cause")
  public String error_with_cause() {
    setSpanAttributes();
    try {
      root_cause();
    } catch (Exception e) {
      throw new RuntimeException("Random error with error cause!", e);
    }
    return "This should never be reached!";
  }

  private void root_cause() {
    throw new RuntimeException("This is the root cause!");
  }

  @GetMapping("/logs")
  public String logs() throws InterruptedException {
    setSpanAttributes();

    // Log4J examples
    // Set ThreadContext key-value:
    ThreadContext.put("threadcontext", "hi");
    Logger logger = LogManager.getLogger("my-logger");

    // StructuredDataMessage:
    StructuredDataMessage structuredMessage = new StructuredDataMessage(
        "LoginAudit", // ID
        "This is a structured data message", // Message
        "auth" // Type (used as structured data category)
    );
    structuredMessage.put("user", "alice");
    structuredMessage.put("status", "success");
    structuredMessage.put("kind", "StructuredDataMessage");
    logger.info(structuredMessage);

    // Just a string:
    logger.info("This is a string log message - log4j");
    ThreadContext.clearAll();

    // java.util.logging examples
    java.util.logging.Logger julLogger = java.util.logging.Logger.getLogger(Controller.class.getName());

    // Log different severity levels
    julLogger.info("Application started - java.util.logging");
    julLogger.log(Level.WARNING, "This is a warning message - java.util.logging");
    julLogger.severe("This is an error message - java.util.logging");

    return "Check the logs!";
  }

  @GetMapping("/metrics")
  public String metrics() throws InterruptedException {
    setSpanAttributes();

    // Get the meter from the global meter provider
    Meter meter = GlobalOpenTelemetry.getMeter("my-app");
    
    // Counter metric
    LongCounter myCounter = meter
      .counterBuilder("my_counter")
      .setDescription("My counter")
      .setUnit("1")
      .build();
    myCounter.add(
      (long) (Math.random() * 25 + 3),
      Attributes.of(AttributeKey.stringKey("my_tag"), "tag_value")
    );

    // Gauge metric (OpenTelemetry Java uses ObservableGauge for async gauges)
    // Get the meter from the global meter provider
    DoubleGauge gauge = meter.gaugeBuilder("my_gauge").build();

    // Record gauge values
    gauge.set(100);
    gauge.set(10);

    // Histogram metric
    DoubleHistogram myHistogram = meter
      .histogramBuilder("my_histogram")
      .setDescription("My Histogram")
      .setUnit("1")
      .build();
    myHistogram.record(
      Math.random() * 16 + 10,
      Attributes.of(AttributeKey.stringKey("my_tag"), "tag_value")
    );

    return "Metrics were sent!";
  }

  @GetMapping("/elasticsearch")
  public String elasticsearch(@RequestParam(required = false) String name) {
    setSpanAttributes();
    
    try {
      List<Map<String, Object>> results;
      if (name != null && !name.isEmpty()) {
        results = elasticsearchService.searchUsersByName(name);
      } else {
        results = elasticsearchService.searchUsers("");
      }
      
      StringBuilder response = new StringBuilder();
      response.append("Elasticsearch query results:<br>");
      for (Map<String, Object> result : results) {
        response.append("User: ").append(result.toString()).append("<br>");
      }
      
      return response.toString();
    } catch (Exception e) {
      return "Error querying Elasticsearch: " + e.getMessage();
    }
  }

  @GetMapping("/")
  public String root() throws InterruptedException {
    setSpanAttributes();

    // Get OpenTelemetry tracer
    Tracer tracer = GlobalOpenTelemetry.getTracer("my-app");
    // Create a new span
    Span span = tracer.spanBuilder("custom-span").startSpan();
    try (Scope scope = span.makeCurrent()) {
      // Do something
      Thread.sleep(10);
      span.setAttribute("custom-attribute", "my custom attribute value");
    } finally {
      // Close the span
        span.end();
    }

    return "<html>" +
           "<body>" +
           "<h1>Java + Spring Boot test setup:</h1>" +
           "<ul>" +
           "<li><a href=\"/slow\">/slow</a></li>" +
           "<li><a href=\"/error\">/error</a></li>" +
           "<li><a href=\"/error_with_cause\">/error_with_cause</a></li>" +
           "<li><a href=\"/logs\">/logs</a></li>" +
           "<li><a href=\"/metrics\">/metrics</a></li>" +
           "<li><a href=\"/elasticsearch\">/elasticsearch</a></li>" +
           "<li><a href=\"/elasticsearch?name=John\">/elasticsearch?name=John</a></li>" +
           "</ul>" +
           "</body>" +
           "</html>";
  }
}
