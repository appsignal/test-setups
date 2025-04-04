package io.opentelemetry.example.graal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import java.util.HashMap;
import java.util.Map;
import org.apache.logging.log4j.message.ObjectMessage;
import org.apache.logging.log4j.message.MapMessage;
import org.apache.logging.log4j.message.StructuredDataMessage;
import org.apache.logging.log4j.ThreadContext;

@RestController
public class Controller {
  @GetMapping("/slow")
  public String slow() throws InterruptedException {
    Thread.sleep(3000);
    return "Well, that took forever!";
  }

  @GetMapping("/error")
  public String error() {
    throw new RuntimeException("Whoops!");
  }

  @GetMapping("/logs")
  public String logs() throws InterruptedException {
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
  public String root() {
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
