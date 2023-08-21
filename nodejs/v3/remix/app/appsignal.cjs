const { Appsignal } = require("@appsignal/nodejs");
const { RemixInstrumentation } = require("opentelemetry-instrumentation-remix");

new Appsignal({
  active: true,
  name: "opentelemetry-remix",
  additionalInstrumentations: [new RemixInstrumentation()],
  disableDefaultInstrumentations: ["@opentelemetry/instrumentation-express"]
});
