const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  name: "opentelemetry-express-redis",
  logLevel: "trace",
  log: "file",
  logPath: "/tmp"
});
