const { Appsignal } = require("@appsignal/nodejs");

new Appsignal({
	active: true,
	name: "express-elasticsearch",
	logLevel: "trace",
});
