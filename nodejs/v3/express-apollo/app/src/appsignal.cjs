const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  name: "opentelemetry-express-apollo",
  logLevel: "trace",
  log: "file",
  logPath: "/tmp"
});