import { pipe, tap } from 'wonka';
import appsignal from './Appsignal';

/**
 * Custom urql exchange that automatically reports GraphQL errors to AppSignal.
 *
 * This exchange intercepts all query/mutation results and reports any errors
 * to AppSignal without requiring changes to individual useQuery calls.
 *
 * Add this to your urql client's exchanges array:
 *
 * import { createClient, fetchExchange } from 'urql';
 * import { appsignalExchange } from './appsignalExchange';
 *
 * const client = createClient({
 *   url: 'https://api.example.com/graphql',
 *   exchanges: [appsignalExchange, fetchExchange]
 * });
 */
export const appsignalExchange = ({ forward, client }) => ops$ => {
  return pipe(
    forward(ops$),
    tap(result => {
      if (result.error) {
        const { error, operation } = result;

        // Convert CombinedError to a proper Error with meaningful message
        const errorMessage = error.graphQLErrors?.length > 0
          ? error.graphQLErrors.map(e => e.message).join(', ')
          : error.message;

        const reportError = new Error(`GraphQL Error: ${errorMessage}`);
        reportError.name = 'GraphQLError';
        reportError.stack = error.stack || reportError.stack;

        // Add additional context
        if (error.graphQLErrors?.length > 0) {
          reportError.graphQLErrors = error.graphQLErrors;
        }
        if (error.networkError) {
          reportError.networkError = error.networkError;
        }

        // Send error to AppSignal with metadata
        appsignal.sendError(reportError, (span) => {
          // Add endpoint URL as a tag
          if (client?.url) {
            span.setTags({ endpoint: client.url });
          }

          // Add GraphQL query body as a param
          if (operation?.query) {
            const queryBody = operation.query.loc?.source?.body;
            if (queryBody) {
              span.setParams({ query: queryBody });
            }
          }

          // Add operation metadata
          if (operation?.operationName) {
            span.setTags({ operationName: operation.operationName });
          }
          if (operation?.kind) {
            span.setTags({ operationType: operation.kind });
          }
        });
      }
    })
  );
};
