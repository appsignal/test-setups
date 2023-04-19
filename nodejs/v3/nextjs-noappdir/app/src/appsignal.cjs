const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  disableDefaultInstrumentations: [
    "@opentelemetry/instrumentation-http"
  ],
  logLevel: "trace",
});

console.log("Appsignal instantiated!")
