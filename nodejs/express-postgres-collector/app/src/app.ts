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
  res.write("<li><a href='/npo/100'>/npo/100</a></li>")
  res.write("<li><a href='/npo-db/100'>/npo-db/100</a></li>")
  res.write("<li><a href='/npo-error/100'>/npo-error/100</a></li>")
  res.write("<li><a href='/npo-nested'>/npo-nested</a></li>")
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

app.get("/npo/:count", async (req, res) => {
  const npoCount = parseInt(req.params.count ?? 100)

  let i = 0;
  while (i < npoCount) {
    await delay(1);
    tracer.startActiveSpan("npo_span", async (span: Span) => {
      await delay(1);
      span.setAttribute("foo", "bar");
      span.end();
    });
    i++;
  }
  res.send("done");
});

app.get("/npo-db/:count", async (req, res) => {
  const npoCount = parseInt(req.params.count ?? 10);

  const results = []
  let i = 0
  while (i < npoCount) {
    const result = await pgPool.query("SELECT $1 * 2 AS doubled", [i])
    results.push({ i, doubled: result.rows[0].doubled })
    i++;
  }

  res.send(`N+1 query! Results: ${JSON.stringify(results)}`)
})


app.get("/npo-error/:count", async (req, res) => {
  const npoCount = parseInt(req.params.count ?? 10)

  let i = 0;
  while (i < npoCount) {
    await delay(1);
    tracer.startActiveSpan("npo_with_errors", async (span: Span) => {
      await delay(1);
      span.setAttribute("foo", "bar");
      await fetch("http://localhost:4001/error");
      span.end();
    });
    i++;
  }
  res.send("done");
});

app.get("/npo-nested", async (_req, res) => {
  for (const i of [1, 2, 3, 4, 5]) {
    await delay(50)

    tracer.startActiveSpan("parent_span", async (span: Span) => {
      await delay(50)
      span.setAttribute("i", i)

      for (const j of [1, 2, 3]) {
        await delay(50)
        tracer.startActiveSpan("child_span", async (span: Span) => {
          await delay(50)
          span.setAttribute("i", i)
          span.setAttribute("j", j)

          span.end()
        })
      }

      span.end()
    })
  }
  res.send("done")
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

function delay(ms: number): Promise<any> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

function randomRangeValue(start: number, end: number) {
  return Math.floor(Math.random() * (end - start)) + start
}
