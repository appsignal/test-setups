const { Appsignal } = require("@appsignal/nodejs");
const { BullMQInstrumentation } = require("@jenniferplusplus/opentelemetry-instrumentation-bullmq");

new Appsignal({
  active: true,
  additionalInstrumentations: [
    new BullMQInstrumentation()
  ]
});
