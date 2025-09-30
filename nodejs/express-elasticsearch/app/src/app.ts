import express, { Response, Request } from "express"
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
app.use(express.json())

app.get("/", (_req: any, res: any) => {
	logger.info("Home path")
	res.sendStatus(200)
})

type Product = {
	name: string
	price: number
	category: string
	featured: boolean
}

const PRODUCT_INDEX = "products"

app.get("/cluster-info", (_req: Request, res: Response) => {
	client.info()
		.then((r) => {
			res.json({ message: "Got cluster info", info: r })
		}).catch((err) => console.log(err))
})

// create index
app.post("/index", (_req: Request, res: Response) => {
	client.indices
		.create({
			index: PRODUCT_INDEX,
			mappings: {
				properties: {
					name: { type: "text" },
					price: { type: "integer" },
					category: { type: "keyword" },
					featured: { type: "boolean" },
				}
			}
		})
		.then((r) => {
			res.send(r)
		})
		.catch((err) => console.log(err))
})

// delete index
app.delete("/index", (_req: Request, res: Response) => {
	client.indices
		.delete({ index: PRODUCT_INDEX })
		.then(() => {
			res.sendStatus(200)
		})
		.catch((err) => console.log(err))
})

// index document
app.post("/products", (req: Request, res: Response) => {
	const { name, price = 100, category = "books", featured = false } = req.body
	client
		.index({
			index: PRODUCT_INDEX,
			document: {
				name: name ?? getRandomName(),
				price,
				category,
				featured,
			},
		})
		.then((r) => {
			res.json({ message: "Product indexed", id: r._id })
		})
		.catch((err) => console.log(err))
})

// bulk index
app.post("/products/bulk", (_req: Request, res: Response) => {
	const products = [
		{ name: getRandomName(), price: 100, category: "books", featured: false },
		{ name: getRandomName(), price: 200, category: "magazines", featured: true },
	]
	const operations = products.flatMap(doc => [{ index: { _index: PRODUCT_INDEX } }, { ...doc }])

	client
		.bulk({ operations })
		.then((r) => {
			res.json({
				"message": "Bulk indexing completed",
				"items": r.items,
				"errors": r.errors,
			})
		})
		.catch((err) => console.log(err))
})

// search
app.get("/products/search", (req: Request, res: Response) => {
	client.search<Product>({
		index: PRODUCT_INDEX,
		query: {
			match: {
				name: {
					query: req.query.query as string,
				}
			}
		}
	})
		.then((r) => {
			res.json({
				hits: r.hits.total,
				products: r.hits.hits.map(hit => ({
					id: hit._id,
					score: hit._score,
					...hit._source,
				})),
			})
		})
		.catch((e) => console.log(e))
})

// get document
app.get("/products/:product_id", (req: Request, res: Response) => {
	client
		.get<Product>({
			index: PRODUCT_INDEX,
			id: req.params.product_id,
		})
		.then((r) => {
			res.json({ result: r })
		})
		.catch((err) => console.log(err))
})

// update document
app.put("/products/:product_id", (req: Request, res: Response) => {
	client
		.update<Product>({
			index: PRODUCT_INDEX,
			id: req.params.product_id,
			doc: req.body
		})
		.then((r) => {
			res.json({ message: 'Product updated', result: r })
		})
		.catch((err) => console.log(err))
})

// delete document
app.delete("/products/:product_id", (req: Request, res: Response) => {
	client
		.delete({
			index: PRODUCT_INDEX,
			id: req.params.product_id,
		})
		.then((r) => {
			res.json({ message: 'Product deleted', result: r })
		})
		.catch((e) => console.log(e))
})


app.get("/custom", (_req: Request, res: Response) => {
	logger.info("custom route")
	setCustomData({ custom: "data" })

	trace.getTracer("custom").startActiveSpan("Custom span", span => {
		setTag("custom", "tag")
		span.end()
	})
	res.send("200 OK")
})

app.use(expressErrorHandler())

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`)
})

function getRandomName(): string {
	const id = Math.round(Math.random() * 100)
	return `Product-${id}`
}
