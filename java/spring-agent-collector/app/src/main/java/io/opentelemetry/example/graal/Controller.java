package io.opentelemetry.example.graal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

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
