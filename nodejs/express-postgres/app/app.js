const { appsignal } = require("./appsignal");

const express = require('express')
const app = express()

const { expressMiddleware } = require("@appsignal/express");
const { expressErrorHandler } = require("@appsignal/express");

app.use(expressMiddleware(appsignal));
app.use(expressErrorHandler(appsignal));

app.get('/', (req, res) => {
  console.log("Request on /")
  res.send('Hello World!')
})

app.listen(3000, () => {
  console.log('Example app listening')
})
