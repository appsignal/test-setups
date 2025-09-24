import express, { Request } from "express"
import { Client } from "@elastic/elasticsearch"
import { setTag, setCustomData, expressErrorHandler, WinstonTransport } from "@appsignal/nodejs"
import { trace } from "@opentelemetry/api"
import cookieParser from "cookie-parser"
import winston from "winston"

const { combine, printf } = winston.format

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
}

const customformat = printf(({ level, message, label, timestamp }) => {
	return `${timestamp} [${label}] ${level}: ${message}`
})

const logger = winston.createLogger({
	level: "trace",
	levels: customLogLevels.levels,
	format: combine(customformat),
	transports: [
		new WinstonTransport({ group: "app" }),
	],
})

const client = new Client({
	node: process.env.ELASTIC_URL,
})

const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

app.get("/", (_req: any, res: any) => {
	logger.info("Home path")
	logger.alert("Custom alert log")
	logger.emerg("Custom emerg(ency) log")
	logger.crit("Custom crit(ical) log")
	res.send("200 OK")
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


app.post("/docs", (_req: any, res: any, next: any) => {
	client.index({
		index: 'something',
		id: 'something_id',
		document: {
			foo: 'foo',
			bar: 'bar',
		},
	}).then((doc) => {
		console.log("created doc", { doc })
		res.sendStatus(200)
		next()
	})
})

app.get("/docs/:doc_id", (req: Request, res: any, next: any) => {
	console.log("====================================================");
	console.log({ params: req.params });
	client.get({
		index: 'something',
		id: req.params.doc_id,
	}).then((doc) => {
		console.log("found doc", { doc })
		res.send(doc)
		next()
	}).catch((err) => {
		console.log({ err })
	})
})

app.use(expressErrorHandler())

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`)
})
