const  {app, appsignal}  = require("./express")

const { createApolloPlugin } = require("@appsignal/apollo-server");
const { ApolloServer, gql } = require("apollo-server");

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

// ADD THIS AFTER ANY OTHER EXPRESS MIDDLEWARE, AND AFTER ANY ROUTES!
app.use(expressErrorHandler(appsignal))

server.listen(4001).then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
