import appsignal from "./appsignal";

window.testSendError = function() {
  console.log("Sending error with Appsignal.sendError");
  appsignal.sendError(
    new Error("sendError arguments test"),
    { arguments: "only tags", tag1: "value 1", tag2: "value 2" }
  )
  appsignal.sendError(
    new Error("sendError arguments test"),
    { arguments: "tags and namespace", tag1: "value 1", tag2: "value 2" },
    "custom"
  )
  appsignal.sendError(new Error("sendError callback test"), function(span) {
    span.setAction("SendErrorTestAction");
    span.setNamespace("frontend");
    span.setTags({ arguments: "callback", foo: "bar", key: "value" });
  });

  try {
    appsignal.wrap(function() {
      throw new Error("sendError wrap test")
    }, function(span) {
      span.setAction("SendErrorWrapAction");
      span.setNamespace("frontend");
      span.setTags({ arguments: "wrap fn", foo: "bar", key: "value" });
    })
  } catch(e) {
    console.error("Error caught: ", e)
  }
};
