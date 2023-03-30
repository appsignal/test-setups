const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  name: "opentelemetry-restify",
  logLevel: "trace",
  log: "file",
  logPath: "/tmp"
});
