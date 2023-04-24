const { appsignal } = require("./appsignal");
const express = require("express");
const app = express();
const { expressMiddleware } = require("@appsignal/express");

app.use(expressMiddleware(appsignal));

module.exports = {app, appsignal};
