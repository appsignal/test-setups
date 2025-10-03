const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
	active: true,
	logLevel: "trace",
});
