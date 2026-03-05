import { useEffect } from 'react';
import { useQuery, useClient } from 'urql';
import appsignal from './Appsignal';

/**
 * Custom hook that wraps urql's useQuery and automatically reports
 * GraphQL errors to AppSignal.
 *
 * This is necessary because urql returns errors as data (in the error field)
 * rather than throwing them, so React's ErrorBoundary doesn't catch them.
 */
export function useAppsignalQuery(options) {
  const [result] = useQuery(options);
  const client = useClient();
  const { error, operation } = result;

  useEffect(() => {
    if (error) {
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

        // Add GraphQL query body as a param (equivalent to "body" in backend integrations)
        if (operation?.query) {
          const queryBody = operation.query.loc?.source?.body || options.query;
          if (queryBody) {
            span.setParams({ query: queryBody });
          }
        } else if (options.query) {
          span.setParams({ query: options.query });
        }
      });
    }
  }, [error, client, operation, options.query]);

  return [result];
}
