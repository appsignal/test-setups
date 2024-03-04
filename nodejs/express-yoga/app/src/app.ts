import express from "express"
import { createSchema, createYoga } from "graphql-yoga"
import {
  expressErrorHandler,
  setRootName,
  setNamespace,
  setTag,
  setSessionData,
  setParams,
  setHeader,
  setCustomData,
  setCategory,
  setName,
  setBody
} from "@appsignal/nodejs"
import { trace, Span } from "@opentelemetry/api"

const port = process.env.PORT
const app = express()

const typeDefs = /* GraphQL */ `
  # This "Book" type defines the queryable fields for every book in our data source.
  type Book {
    title: String
    author: String
  }
  type Author {
    author: String
  }
  type Query {
    books: [Book]
    authors: [Author]
  }
`

const books = [
  {
    title: "The Awakening",
    author: "Kate Chopin"
  },
  {
    title: "City of Glass",
    author: "Paul Auster"
  }
]

const resolvers = {
  Query: {
    books: () => books
  }
}

const yogaServer = createYoga({
  schema: createSchema({
    typeDefs: typeDefs,
    resolvers: resolvers
  })
})

app.use("/graphql", yogaServer)

app.get("/", (_req, res) => {
  res.send('<a href="/graphql">Apollo Panel</a>')
})

app.get("/error", (req, res) => {
  throw new Error("Expected test error")
})

app.get("/slow", async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("Well, that took forever!")
})


app.get("/custom_instrumentation", async (_req, res) => {
  const tracer = trace.getTracer('custom');

  await tracer.startActiveSpan("fetch.company", async (span: Span) => {
    setCategory("company.get.street.sorci");
    setName("Fetching company details");
    setBody("Some span body");
    await new Promise(resolve => setTimeout(resolve, 1000));
    span.end();
  })

  await tracer.startActiveSpan('persist.company', async (span: Span) => {
    setCategory("company.persist.street.sorci");
    setName("Persist company details");
    setBody("Some span body");
    await new Promise(resolve => setTimeout(resolve, 1000));
    span.end();
  })

  setRootName("GET /custom_instrumtation action");
  setNamespace("custom");
  setTag("tag1", "value1")
  setTag("tag2", 123)
  setSessionData({ _csrf_token: "Z11CWRVG+I2egpmiZzuIx/qbFb/60FZssui5eGA8a3g=" })
  setParams({ action: "show", controller: "homepage" })
  setHeader("CUSTOM_HEADER", "custom header value")
  setCustomData({ stroopwaffle: "true", coffee: "false" })
  res.send("Custom instrumentation set")
})

app.use(expressErrorHandler())

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
