import { createClient, fetchExchange } from 'urql';
import { createAppsignalExchange } from '@appsignal/urql';
import appsignal from './Appsignal';

// Create a urql client with a mock GraphQL endpoint
// Since we're testing error reporting, we'll use a URL that returns errors
export const client = createClient({
  url: 'https://rickandmortyapi.com/graphql', // Public GraphQL API for testing
  // You can also use: url: 'http://localhost:4000/graphql' for a local endpoint
  exchanges: [createAppsignalExchange(appsignal), fetchExchange]
});
