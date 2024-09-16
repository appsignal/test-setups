import express from "express"
import { createClient } from "redis"
import ioredis from "ioredis"
import { setTag, setCustomData, expressErrorHandler, WinstonTransport, checkIn } from "@appsignal/nodejs"
import { trace } from "@opentelemetry/api"
import cookieParser from "cookie-parser"
import winston from "winston"

const { combine, label, printf } = winston.format;

const customLogLevels = {
  levels: {
    trace: 8,
    debug: 7,
    info: 6,
    notice: 5,
    warn: 4,
    error: 3,
    crit: 2,
    alert: 1,
    emerg: 0,
  },
};

const customformat = printf(({ level, message, label, timestamp }) => {
  return `${timestamp} [${label}] ${level}: ${message}`;
});

const logger = winston.createLogger({
  level: "trace",
  levels: customLogLevels.levels,
  format: combine(customformat),
  transports: [
    new WinstonTransport({ group: "app" }),
  ],
});

const redisHost = "redis://redis:6379"
const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

app.get("/", (_req: any, res: any) => {
  logger.info("Home path");
  logger.alert("Custom alert log");
  logger.emerg("Custom emerg(ency) log");
  logger.crit("Custom crit(ical) log");
  res.send("200 OK")
})

app.get("/error", (_req: any, _res: any) => {
  logger.error("Expected test error!");
  throw new Error("Expected test error!")
})

app.get("/redis", async (_req: any, res: any, next: any) => {
  logger.debug("Redis path")
  try {
    const client = createClient({ url: redisHost })
    client.once("error", (error: Error) => {
      next(error)
    })

    await client.connect()
    await client.set("test_key", "Test value")
    const value = await client.get("test_key")
    res.send(`
      <h1>OpenTelemetry Redis 4 example</h1>
      <p>The query result should be "Test value": ${value}</p>
    `)
  } catch (e) {
    next(e)
  }
})

app.get("/ioredis", async (_req: any, res: any, next: any) => {
  logger.warn("ioredis Path")
  try {
    const client = new ioredis(redisHost)
    await client.set("test_key", "Test value")
    const value = await client.get("test_key")
    res.send(`
      <h1>OpenTelemetry ioredis example</h1>
      <p>The query result should be "Test value": ${value}</p>
    `)
  } catch (e) {
    next(e)
  }
})

app.get("/custom", (_req: any, res: any) => {
  logger.info("custom route")
  setCustomData({ custom: "data" })

  trace.getTracer("custom").startActiveSpan("Custom span", span => {
    setTag("custom", "tag")

    span.end()
  })

  res.send("200 OK")
})

app.get("/slow", async (_req: any, res: any) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("Well, that took forever!")
})

app.get("/route-param/:id", (req, res) => {
  res.send(`Route parameter <code>id</code>: ${req.params.id}`)
})

app.get("/cron", async (req, res) => {
  await checkIn.cron("custom-cron-checkin", () => 
    new Promise((resolve) => setTimeout(resolve, 3000))
  )
  
  res.send("Cron check-in sent!")
})

app.get("/heartbeat", async (req, res) => {
  checkIn.heartbeat("custom-heartbeat-checkin")

  res.send("Heartbeat check-in sent!")
})

checkIn.heartbeat("continuous-heartbeat-checkin", {continuous: true})

app.get("/fetch", async (req, res, next) => {
  try {
    const response = await fetch("https://google.com")
    res.send(`Fetched google.com: status code ${response.status}`)
  } catch (e) {
    next(e)
  }
})

app.use(expressErrorHandler())

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
