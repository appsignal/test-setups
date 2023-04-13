const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
  active: true
});

console.log("Appsignal instantiated!")
