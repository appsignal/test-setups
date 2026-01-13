import { Pool } from "pg"
import express from "express"
import { Span, trace, metrics } from "@opentelemetry/api"

const tracer = trace.getTracer('my-tracer');

const pgPool = new Pool()
const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))

app.get("/", (_req: any, res: any) => {
  tracer.startActiveSpan("custom_span", (span: Span) => {
    span.setAttribute("appsignal.request.parameters", JSON.stringify({
      "password": "super secret",
      "email": "test@example.com",
      "cvv": 123,
      "test_param": "test value",
      "nested": {
        "password": "super secret nested",
        "test_param": "test value",
      }
    }))
    span.setAttribute("appsignal.request.session_data", JSON.stringify({
      "token": "super secret",
      "user_id": 123,
      "test_param": "test value",
      "nested": {
        "token": "super secret nested",
        "test_param": "test value",
      }
    }))
    span.setAttribute("appsignal.function.parameters", JSON.stringify({
      "hash": "super secret",
      "salt": "shoppai",
      "test_param": "test value",
      "nested": {
        "hash": "super secret nested",
        "test_param": "test value",
      }
    }))

    span.end();
  });

  res.write("<h1>Node.js OpenTelemetry example app</h1>")
  res.write("<ul>")
  res.write("<li><a href='/slow'>/slow</a></li>")
  res.write("<li><a href='/error'>/error</a></li>")
  res.write("<li><a href='/pg-query'>/pg-query</a></li>")
  res.write("<li><a href='/metrics'>/metrics</a></li>")
  res.write("<li><a href='/n-plus-one'>/n-plus-one</a></li>")
  res.write("</ul>")
  res.end()
})

app.get("/error", (req, res) => {
  throw new Error("Expected test error without reporter!")
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

const meter = metrics.getMeter(
  "instrumentation-scope-name",
  "1.0.0",
);

function randomRangeValue(start: number, end: number) {
  return Math.floor(Math.random() * (end - start)) + start
}

app.get("/n-plus-one", async (_req, res) => {
  const ids = [1, 2, 3, 4, 5]

  // N queries: one query per ID (the "N" in N+1)
  const results = []
  for (const id of ids) {
    const detailResult = await pgPool.query("SELECT $1 * 2 AS doubled", [id])
    results.push({ id, doubled: detailResult.rows[0].doubled })
  }

  res.send(`N+1 query! Results: ${JSON.stringify(results)}`)
})

app.get("/metrics", (_req, res) => {
  // Counter
  const myCounter = meter.createCounter("my_counter")
  const countValue = randomRangeValue(1, 3)
  myCounter.add(countValue, { "my_tag": "tag_value" })

  // Gauge
  const myGauge = meter.createGauge("my_gauge")
  const gaugeValue = randomRangeValue(1, 25)
  myGauge.record(gaugeValue, { "my_tag": "tag_value" })

  // Histogram
  const histogram = meter.createHistogram("my_histogram")
  const histogramValue = randomRangeValue(10, 25)
  histogram.record(histogramValue, { "my_tag": "tag_value" })

  res.send("I sent some test metrics!")
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
