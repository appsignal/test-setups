import _ from 'lodash';
import Appsignal from "./Appsignal"

function sendError() {
  try {
    throw new Error("I am an error");
  } catch (e) {
    const span = Appsignal.createSpan((span) => {
      span.setError(e);
      span.setAction("MyCustomAction");
      span.setTags({
        tag: "value"
      });
    });
    Promise.all([Appsignal.send(span)]);
  }
}

function throwError() {
  throw new Error("I am an error");
}

function component() {
  const element = document.createElement('div');

  // Lodash, now imported by this script
  element.innerHTML = _.join([
    "Hello webpack",
    "test app!<br>",
    "We are running release:",
    APPSIGNAL_REVISION
  ], " ");

  Appsignal.demo();

  return element;
}

document.body.appendChild(component());

sendError();
throwError();
