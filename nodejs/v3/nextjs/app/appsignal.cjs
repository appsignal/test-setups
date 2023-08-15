const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  name: "nodejs/nextjs",
  pushApiKey: "4ba6f264-d8e9-4e41-853e-15600e39e8b6",
  disableDefaultInstrumentations: [
    // Add the following line inside the list
    "@opentelemetry/instrumentation-http",
  ],
});
