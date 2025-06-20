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

@RestController
public class Controller {

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
    throw new RuntimeException("Whoops!");
  }

  @GetMapping("/logs")
  public String logs() throws InterruptedException {
    setSpanAttributes();

    for (int i = 0; i < 10; i++) {
      // Set ThreadContext key-value:
      ThreadContext.put("something", "threadcontext");
      Logger logger = LogManager.getLogger("my-logger");
      // StructuredDataMessage:
      StructuredDataMessage structuredMessage = new StructuredDataMessage(
          "LoginAudit", // ID
          String.format("This is a structured data message #%s", i), // Message
          "auth" // Type (used as structured data category)
      );
      structuredMessage.put("user", "alice");
      structuredMessage.put("status", "success");
      structuredMessage.put("kind", "StructuredDataMessage");
      logger.info(structuredMessage);
      // MapMessage:
      MapMessage mapMessage = new MapMessage()
          .with("user", "alice")
          .with("action", "login")
          .with("number", String.format("%s", i))
          .with("kind", "MapMessage");
      logger.info(mapMessage);
      // ObjectMessage:
      Map<String, String> map = new HashMap<>();
      map.put("user", "alice");
      map.put("action", "login");
      map.put("number", String.format("%s", i));
      map.put("kind", "ObjectMessage");
      ObjectMessage objectMessage = new ObjectMessage(map);
      logger.info(objectMessage);
      // Just a string:
      logger.info(String.format("This is a string log message #%s", i));
      ThreadContext.clearAll();

      Thread.sleep(10);
    }

    return "Check the logs!";
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
           "<li><a href=\"/logs\">/logs</a></li>" +
           "</ul>" +
           "</body>" +
           "</html>";
  }
}
