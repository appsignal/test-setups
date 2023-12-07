import express from "express"
import { ApolloServer, gql } from "apollo-server-express"
import { expressErrorHandler } from "@appsignal/nodejs"

const port = process.env.PORT
const app = express()

app.use(express.urlencoded({ extended: true }))

const typeDefs = gql`
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

const apolloServer = new ApolloServer({
  typeDefs,
  resolvers
})

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

apolloServer.applyMiddleware({ app })

app.use(expressErrorHandler())

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
