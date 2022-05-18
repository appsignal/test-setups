import { Appsignal } from '@appsignal/nodejs';
import { createApolloPlugin } from '@appsignal/apollo-server';

const appsignal = new Appsignal({
  active: true,
  name: "Pythia",
  pushApiKey: process.env.APPSIGNAL_PUSH_API_KEY,
  log_level: "trace",
  logPath: "logs"
});

require('dotenv').config();

import http from 'http';
import { makeExecutableSchema } from '@graphql-tools/schema';
import type { TypeSource, IResolvers } from '@graphql-tools/utils';
import { RequestContext } from '@mikro-orm/core';
import { ApolloServerPluginDrainHttpServer, gql } from 'apollo-server-core';
import { ApolloServer } from 'apollo-server-koa';
import { applyMiddleware } from 'graphql-middleware';
import Koa from 'koa';

import db, { initialize as initializeDatabase } from '@/db';
import BlogPost from '@/db/BlogPost';


const config = {
  server: {
    port: 8000,
  },
  graphqlApiPath: '/api',
};

const typeDefs = gql`
  type Post {
    title: String
    content: String
  }

  type Query {
    posts: [Post]
  }
`;

const resolvers = { Query: { posts: () => [db.orm.em.getRepository(BlogPost)] }};
const permissions = {};



const {
  server: {
    port: serverPort,
  },
  graphqlApiPath,
} = config;

const app = new Koa();

app.use((ctx, next) => RequestContext.createAsync(db.orm.em, next));

interface StartServerParams {
  typeDefs: TypeSource;
  resolvers: IResolvers;
}

async function startServer(apolloServerParams: StartServerParams) {
  await initializeDatabase();

  const httpServer = http.createServer();
  const schema = makeExecutableSchema(apolloServerParams);
  const schemaWithPermissions = applyMiddleware(schema, permissions);

  const server = new ApolloServer({
    schema: schemaWithPermissions,
    context: ({ ctx, connection }) => {
      if (connection) {
        return connection.context;
      }

      // Query or Mutation
      // return {
      //   client: ctx.client,
      //   isAuthenticated: ctx.isAuthenticated(),
      // };
    },
    formatError(err) {
      console.error(err);

      err.message = err.message || 'Internal server error. Please contact the administrator';

      return err;
    },
    plugins: [ApolloServerPluginDrainHttpServer({ httpServer }), createApolloPlugin(appsignal) as any],
  });

  await server.start();
  server.applyMiddleware({ app, path: graphqlApiPath });
  httpServer.on('request', app.callback());

  // eslint-disable-next-line no-promise-executor-return
  await new Promise<void>(resolve => httpServer.listen({ port: serverPort }, resolve));

  return { server, app };
}

void startServer({ typeDefs, resolvers });
