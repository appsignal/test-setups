import express, { Response, Request } from "express"
import { Client } from "@elastic/elasticsearch"
import { expressErrorHandler } from "@appsignal/nodejs"
import cookieParser from "cookie-parser"
import { IndicesCreateResponse, SearchHit } from "@elastic/elasticsearch/lib/api/types"

type Product = {
	name: string
	price: number
	category: string
	featured: boolean
}

const PRODUCT_INDEX = "products"

const client = new Client({
	node: process.env.ELASTIC_URL,
})

// this is async, should be fine for demo
createProductIndex()

const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())
app.use(express.json())

app.get("/", (_req: any, res: any) => {
	client.search<Product>({
		index: PRODUCT_INDEX,
		query: {
			match_all: {}
		},
	})
		.then(r => {
			const docs = r.hits.hits
			res.send(getHtmlLinks(docs))
		})
		.catch(err => {
			if (err.meta.statusCode === 404) {
				res.send(getInitialHtml())
				return
			}

			res.status(500).send(err)
		})
})

// cluster info
app.get("/cluster-info", (_req: Request, res: Response) => {
	client.info()
		.then((r) => {
			res.json({ message: "Got cluster info", info: r })
		}).catch((err) => res.status(500).send(err))
})

// create index
app.post("/index", (_req: Request, res: Response) => {
	createProductIndex()
		.then((r) => {
			res.send(r)
		})
		.catch((err) => res.status(500).send(err))
})

// delete index
app.delete("/index", (_req: Request, res: Response) => {
	client.indices
		.delete({ index: PRODUCT_INDEX })
		.then((r) => {
			res.send(r)
		})
		.catch((err) => res.status(500).send(err))
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
		.catch((err) => res.status(500).send(err))
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
		.catch((err) => res.status(500).send(err))
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
		.catch((err) => res.status(500).send(err))
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
		.catch((err) => res.status(500).send(err))
})

// update document
app.put("/products/:product_id", (req: Request, res: Response) => {
	client
		.update<Product>({
			index: PRODUCT_INDEX,
			id: req.params.product_id,
			doc: { name: req.body?.name ?? getRandomName() },
		})
		.then((r) => {
			res.json({ message: 'Product updated', result: r })
		})
		.catch((err) => res.status(500).send(err))
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
		.catch((err) => res.status(500).send(err))
})

app.use(expressErrorHandler())

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`)
})

function getRandomName(): string {
	const id = Math.round(Math.random() * 100)
	return `Product-${id}`
}

function createProductIndex(): Promise<IndicesCreateResponse | string> {
	return client.indices.exists({ index: PRODUCT_INDEX })
		.then(exists => {
			if (!exists) {
				return client.indices
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
			} else {
				return new Promise((resolve) => {
					resolve("Index exists")
				})
			}
		})
}

function mapToHtmlList(documents: Array<SearchHit<Product>>, callback: (doc: SearchHit<Product>) => string): string {
	let list = '<ul>'
	for (const doc of documents) {
		list += `<li>${callback(doc)}</li>`
	}
	list += '</ul>'

	return list
}

function getInitialHtml() {
	return `
		<h1>Elasticsearch (Express) example </h1>
		<p>"${PRODUCT_INDEX}" index is missing</p>
		<form method="POST" action="/index"><button>Create index</button></form>
	`
}

function getHtmlLinks(docs: Array<SearchHit<Product>>): string {
	const productGetList = mapToHtmlList(docs, (doc) => `<a href="/products/${doc._id}">${doc._source?.name}</a>`)
	const productUpdateList = mapToHtmlList(docs, (doc) => `<form onsubmit="event.preventDefault();fetch('/products/${doc._id}', {method: 'PUT', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({name: this.name.value})}).then(r => r.text()).then(res => { const blob = new Blob([res], {type: 'application/json'}); window.location.href = window.URL.createObjectURL(blob); })"><input name="name" value="${doc._source?.name}"><button>Update</button></form>`)
	const productDeleteList = mapToHtmlList(docs, (doc) => `<button onclick="fetch('/products/${doc._id}', {method: 'DELETE'}).then(r => r.text()).then(res => { const blob = new Blob([res], {type: 'application/json'}); window.location.href = window.URL.createObjectURL(blob); })">${doc._source?.name}</button>`)

	return `
		<h1>Elasticsearch (Express) example</h1>
		<p>POST, PUT and DELETE requests will return json responses in the same tab. Refresh "/" page to see updates.</p>
		<p>Try these routes:</p>
		<ul>
			<li><a href="/cluster-info">Cluster info</a></span>
			<li><h2>Indices</h2>
				<ul>
					<li><form method="POST" action="/index"><button>Create "${PRODUCT_INDEX}" index</button></form></li>
					<li><button onclick="fetch('/index', {method: 'DELETE'}).then(r => r.text()).then(res => { const blob = new Blob([res], {type: 'application/json'}); window.location.href = window.URL.createObjectURL(blob); })">Delete "${PRODUCT_INDEX}" index</button></li>
				</ul>
			</li>
			<li><h2>Documents</h2>
				<ul>
					<li><h3>Create</h3><form method="POST" action="/products"><input name="name" placeholder="Product name..." type="text"><button>Create</button></form></li>
					<li><h3>Bulk create</h3><form method="POST" action="/products/bulk"><button>Bulk create</button></form></li>
					<li><h3>Search</h3><form method="GET" action="/products/search"><input name="query" type="text" placeholder="Search by product name..."><button>Search</button></form></li>
					<li><h3>Get</h3>${productGetList}</li>
					<li><h3>Update</h3>${productUpdateList}</li>
					<li><h3>Delete</h3>${productDeleteList}</li>
				</ul>
			</li>
		</ul>
	`
}
