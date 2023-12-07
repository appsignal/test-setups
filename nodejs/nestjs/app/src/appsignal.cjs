const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true,
  pushApiKey: "not-a-real-api-key"
});
