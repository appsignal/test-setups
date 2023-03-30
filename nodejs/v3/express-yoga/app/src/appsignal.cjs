const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  name: "opentelemetry-express-yoga",
  logLevel: "trace",
  log: "file",
  logPath: "/tmp"
})
