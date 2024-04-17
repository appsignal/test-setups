const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  disableDefaultInstrumentations: [
    // Add the following line inside the list
    "@opentelemetry/instrumentation-http",
  ],
});
