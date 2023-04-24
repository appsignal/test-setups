const { Appsignal } = require("@appsignal/nodejs");

// Gets the config from the environment
const appsignal = new Appsignal({
  "active": true
});

console.log("Starting appsignal");
console.log(appsignal);

exports.appsignal = appsignal;
