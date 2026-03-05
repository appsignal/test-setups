import { useEffect } from 'react';
import { useQuery } from 'urql';
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
  const { error } = result;

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

      appsignal.sendError(reportError);
    }
  }, [error]);

  return [result];
}
