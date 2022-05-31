require("./tracing.js");

const { appsignal } = require("./appsignal");
const opentelemetry = require("@opentelemetry/api");
const express = require("express");
const { expressMiddleware } = require("@appsignal/express");
const { tracer } = require("./tracing.js");
const { promisify } = require("util");
const bodyParser = require('body-parser');
const redis = require('redis')
const ioredis = require('ioredis')
const app = express();
app.use(expressMiddleware(appsignal));
app.use(bodyParser.urlencoded({ extended: true }));

const redisHost = "redis://redis:6379";

opentelemetry.diag.setLogger(new opentelemetry.DiagConsoleLogger(), opentelemetry.DiagLogLevel.DEBUG);

app.get('/', (req, res) => {
  res.send(`
    <h1>OpenTelemetry example app</h1>
    <ul>
      <li><a href="/mysql">/mysql</a></li>
      <li><a href="/mysql2">/mysql2</a></li>
      <li><a href="/redis">/redis</a></li>
      <li><a href="/ioredis">/ioredis</a></li>
      <li><a href="/express-get?get-param1=value-1&get-param2=value-2">/express-get</a></li>
      <li>
        <form action="/express-post" method="post">
          <input type="hidden" name="post-param1" value="value 1">
          <input type="hidden" name="post-param2" value="value 2">
          <button type="submit" name="express-post" value="express-post">/express-post</button>
        </form>
      </li>
      <li><a href="/express-error">/express-error</a></li>
    </ul>
  `)
})

app.get('/mysql', (req, res) => {
  const mysql = require('mysql')
  const connection = mysql.createConnection({
    host: 'mysql',
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
  })

  connection.connect()

  connection.query('SELECT 1 + 1 AS solution', function (err, rows, fields) {
    if (err) throw err

    res.send(`<h1>OpenTelemetry MySQL example</h1><p>The query result should be "2": ${rows[0].solution}</p>`)
  })
  connection.end()
})

app.get('/mysql2', (req, res) => {
  const mysql2 = require('mysql2')
  const connection = mysql2.createConnection({
    host: 'mysql',
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
  })

  connection.connect()

  connection.query('SELECT 1 + 1 AS solution', function (err, rows, fields) {
    if (err) throw err

    res.send(`<h1>OpenTelemetry MySQL2 example</h1><p>The query result should be "2": ${rows[0].solution}</p>`)
  })
  connection.end()
})

app.get('/redis', async (req, res) => {
  const client = redis.createClient({ url: redisHost })
  client.once('error', (error) => { throw error })

  const setAsync = promisify(client.set).bind(client);
  const getAsync = promisify(client.get).bind(client);

  await setAsync("test_key", "Test value")
  const value = await getAsync("test_key")
  res.send(`<h1>OpenTelemetry Redis example</h1><p>The query result should be "Test value": ${value}</p>`)
})

app.get('/ioredis', async (req, res) => {
  const client = new ioredis(redisHost);
  await client.set("test_key", "Test value")
  const value = await client.get("test_key")
  res.send(`<h1>OpenTelemetry ioredis example</h1><p>The query result should be "Test value": ${value}</p>`)
})

app.get('/express-get', async (req, res) => {
  // Dummy query as a child span
  const client = new ioredis(redisHost);
  await client.get("test_key")

  res.send("GET Query received!")
})

app.post('/express-post', async (req, res) => {
  // Dummy query as a child span
  const client = new ioredis(redisHost);
  await client.get("test_key")
  res.json({requestBody: req.body})
})

app.get('/express-error', (req, res) => {
  const childSpan = tracer.startSpan("errorSpan")

  try {
    childSpan.setAttribute("foo", "bar")
    throw new Error("!!! TEST ERROR")
  } catch (e) {
    childSpan.recordException(e)
    childSpan.setStatus({
      code: opentelemetry.SpanStatusCode.ERROR,
      message: e.message
    })

    throw e
  } finally {
    childSpan.end()
  }

  res.send("GET Query received!")
})

app.listen(3000, () => {
  console.log(`Example app listening`)
})
