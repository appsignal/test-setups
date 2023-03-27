const  {app, appsignal}  = require("./express")

const { createApolloPlugin } = require("@appsignal/apollo-server");
const { ApolloServer, gql } = require("apollo-server-express");

const { expressErrorHandler } = require("@appsignal/express")

const fs = require('fs');
// The GraphQL schema
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

  type Query2 {
    readError: String
  }
`;

const books = [
  {
    title: 'The Awakening',
    author: 'Kate Chopin',
  },
  {
    title: 'City of Glass',
    author: 'Paul Auster',
  },
];

// A map of functions which return data for the schema.
const resolvers = {
  Query: {
    books: () => books,
  },
  Query2: {
    readError: (parent, args, context) => {
      fs.readFileSync('/does/not/exist');
    },
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  plugins: [createApolloPlugin(appsignal)],
});

app.get("/", (req, res) => {
  res.send("Hello world! See <a href=\"/graphql\">&sol;graphql</a>")
})

app.get('/error', (req, res) => {
  throw "This is an express-apollo error!"
})

app.get('/slow', async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  res.send("Well, that took forever!")
})

server.applyMiddleware({ app });

// ADD THIS AFTER ANY OTHER EXPRESS MIDDLEWARE, AND AFTER ANY ROUTES!
app.use(expressErrorHandler(appsignal))

app.listen(4001, () => {
  console.log(`🚀 Server ready at http://localhost:4001`);
});
