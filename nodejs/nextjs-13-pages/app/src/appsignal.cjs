const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  disableDefaultInstrumentations: [
    "@opentelemetry/instrumentation-http"
  ],
});

console.log("Appsignal instantiated!")
