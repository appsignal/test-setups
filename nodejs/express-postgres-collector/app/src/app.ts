import { Pool } from "pg"
import express from "express"
import opentelemetry from "@opentelemetry/api"
import { expressErrorHandler } from "./error_reporter"

const pgPool = new Pool()
const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))

app.get("/", (_req: any, res: any) => {
  res.write("<h1>Node.js OpenTelemetry example app</h1>")
  res.write("<ul>")
  res.write("<li><a href='/slow'>/slow</a></li>")
  res.write("<li><a href='/error'>/error</a></li>")
  res.write("<li><a href='/pg-query'>/pg-query</a></li>")
  res.write("<li><a href='/metrics'>/metrics</a></li>")
  res.write("</ul>")
  res.end()
})

app.get("/error", (req, res) => {
  throw new Error("Expected test error")
})

app.get("/slow", async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("Well, that took forever!")
})

app.get("/pg-query", (_req: any, res: any) => {
  pgPool.query("SELECT 1 + 1 AS solution", (err, result) => {
    if (err) {
      throw err
    }

    res.send(`QUERY received! Result: ${result.rows[0]}`)
  })
})

const meter = opentelemetry.metrics.getMeter(
  "instrumentation-scope-name",
  "1.0.0",
);

function randomRangeValue(start: number, end: number) {
  return Math.floor(Math.random() * (end - start)) + start
}

app.get("/metrics", (_req, res) => {
  // Counter
  const myCounter = meter.createCounter("my_counter")
  const countValue = randomRangeValue(1, 3)
  myCounter.add(countValue, {"my_tag": "tag_value"})

  // Gauge
  const myGauge = meter.createGauge("my_gauge")
  const gaugeValue = randomRangeValue(1, 25)
  myGauge.record(gaugeValue, {"my_tag": "tag_value"})

  // Histogram
  const histogram = meter.createHistogram("my_histogram")
  const histogramValue = randomRangeValue(10, 25)
  histogram.record(histogramValue, {"my_tag": "tag_value"})

  res.send("I sent some test metrics!")
})

app.use(expressErrorHandler());

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
