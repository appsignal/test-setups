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

  @GetMapping("/")
  public String root() {
    // Set ThreadContext key-value:
    ThreadContext.put("something", "threadcontext");
    Logger logger = LogManager.getLogger("my-logger");
    // StructuredDataMessage:
    StructuredDataMessage structured = new StructuredDataMessage(
        "LoginAudit", // ID
        "This is a structured data message",
        "auth" // Type (used as structured data category)
    );
    structured.put("user", "alice");
    structured.put("status", "success");
    logger.info(structured);
    // MapMessage:
    MapMessage message = new MapMessage()
        .with("user", "alice")
        .with("action", "login")
        .with("status", "success")
        .with("map", "message");
    logger.info(message);
    // Just a string:
    logger.info("This is a string log message");
    ThreadContext.clearAll();

    return "<html>" +
           "<body>" +
           "<h1>Java + Spring Boot test setup:</h1>" +
           "<ul>" +
           "<li><a href=\"/slow\">/slow</a></li>" +
           "<li><a href=\"/error\">/error</a></li>" +
           "</ul>" +
           "</body>" +
           "</html>";
  }
}
