const { appsignal } = require("./appsignal");
const { expressMiddleware } = require("@appsignal/express");

const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const { expressErrorHandler } = require("@appsignal/express");

app.use(expressMiddleware(appsignal));
app.use(bodyParser.urlencoded({extended: true}));

app.get("/", (req, res) => {
  res.send("Hello world<ul>" +
    "<li><a href='/slow'>Slow request</a></li>" +
    "<li><a href='/error'>Error request</a></li>" +
    "</ul>"
  );
});

app.get("/error", (req, res) => {
  console.log("Request on /error");

  throw new Error("Error in the redis express app");
});

app.get('/slow', async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000));
  res.send("Well, that took forever!");
});

app.use(expressErrorHandler(appsignal));

app.listen(3000, () => {
  console.log('Example app listening')
});
