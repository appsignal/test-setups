import appsignal from "./appsignal";

function addOutput(message) {
  const output = document.getElementById("output")

  const line = document.createElement("code")
  line.innerText = `[${(new Date).toISOString()}] ${message}`

  output.appendChild(line)

  output.scrollTop = output.scrollHeight
}

class NamedError extends Error {
  // Because JS errors predate JS classes, errors have a `name` property on
  // their prototype. JS classes, on the other hand, have a `constructor.name`
  // property on their prototype. So if you want the `name` property of an
  // error to match the name of its class, you have to do this.

  constructor(message) {
    super(message)
    this.name = this.constructor.name
  }
}

class TestSendErrorArguments extends NamedError {}
class TestSendErrorNamespace extends NamedError {}
class TestSendErrorCallback extends NamedError {}
class TestSendErrorWrap extends NamedError {}

window.testSendError = function() {
  addOutput("Sending some errors with Appsignal.sendError");
  
  appsignal.sendError(
    new TestSendErrorArguments("error message"),
    { arguments: "only tags", tag1: "value 1", tag2: "value 2" }
  )
  appsignal.sendError(
    new TestSendErrorNamespace("error message"),
    { arguments: "tags and namespace", tag1: "value 1", tag2: "value 2" },
    "custom"
  )
  appsignal.sendError(new TestSendErrorCallback("error message"), function(span) {
    span.setAction("SendErrorTestAction");
    span.setNamespace("frontend");
    span.setTags({ arguments: "callback", foo: "bar", key: "value" });
  });

  try {
    appsignal.wrap(function() {
      throw new TestSendErrorWrap("error message")
    }, function(span) {
      span.setAction("SendErrorWrapAction");
      span.setNamespace("frontend");
      span.setTags({ arguments: "wrap fn", foo: "bar", key: "value" });
    })
  } catch(e) {
    addOutput("Wrap test error caught")
  }
};

class TestOnError extends NamedError {}

window.testOnError = function() {
  addOutput("Throwing an error for the onError handler");
  
  throw new TestOnError("error message");
}

class TestOnUnhandledRejection extends NamedError {}

window.testOnUnhandledRejection = function() {
  addOutput("Rejecting some promises for the onUnhandledRejection handler");
  
  new Promise((_resolve, reject) => {
    reject(new TestOnUnhandledRejection("error message"))
  })

  new Promise((_resolve, reject) => {
    reject({"onUnhandledRejection": "test object"})
  })

  new Promise((_resolve, reject) => {
    reject("onUnhandledRejection test string")
  })
}

class TestConsoleBreadcrumbs extends NamedError {}

window.testConsoleBreadcrumbs = function() {
  addOutput("Sending an error with some console breadcrumbs");
  
  console.log("Logging something")
  console.warn("Warning about something")

  appsignal.sendError(new TestConsoleBreadcrumbs("error message"))
}

class TestNetworkBreadcrumbs extends NamedError {}

window.testNetworkBreadcrumbs = function() {
  addOutput("Sending an error with some network breadcrumbs");

  fetch("https://pokeapi.co/api/v2/pokemon/ditto").then((_response) => {
    addOutput("Fetched some network resource")
    appsignal.sendError(new TestNetworkBreadcrumbs("error message"))
  })
}

class TestPathDecorator extends NamedError {}

window.testPathDecorator = function() {
  addOutput("Sending an error with the current path")
  appsignal.sendError(new TestPathDecorator("path decorator test"))
}
