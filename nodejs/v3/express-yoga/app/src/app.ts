import express from "express"
import { createServer } from "@graphql-yoga/node"
import { expressErrorHandler } from "@appsignal/nodejs"

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

const yogaServer = createServer({
  schema: {
    typeDefs: typeDefs,
    resolvers: resolvers
  }
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

app.use(expressErrorHandler())

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
