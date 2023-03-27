const { appsignal } = require("./appsignal")
const express = require("express")
const app = express();
const { expressMiddleware } = require("@appsignal/express")

// ADD THIS AFTER ANY OTHER EXPRESS MIDDLEWARE, BUT BEFORE ANY ROUTES!
app.use(expressMiddleware(appsignal));

module.exports = {app, appsignal};