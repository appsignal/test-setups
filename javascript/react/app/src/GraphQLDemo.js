import React from 'react';
import { useQuery } from 'urql';

// GraphQL query that will succeed
const VALID_QUERY = `
  query {
    __typename
  }
`;

// GraphQL query that will fail
const INVALID_QUERY = `
  query {
    nonExistentField {
      id
      name
    }
  }
`;

function GraphQLDemo() {
  const [useInvalidQuery, setUseInvalidQuery] = React.useState(false);
  const [autoTrigger, setAutoTrigger] = React.useState(false);

  // Errors are automatically reported via createAppsignalExchange
  const [result] = useQuery({
    query: useInvalidQuery ? INVALID_QUERY : VALID_QUERY,
  });

  const { data, fetching, error } = result;

  // Auto-trigger errors periodically
  React.useEffect(() => {
    if (autoTrigger) {
      const interval = setInterval(() => {
        setUseInvalidQuery(true);
        setTimeout(() => setUseInvalidQuery(false), 2000);
      }, 5000);
      return () => clearInterval(interval);
    }
  }, [autoTrigger]);

  const triggerGraphQLError = () => {
    setUseInvalidQuery(true);
  };

  const resetQuery = () => {
    setUseInvalidQuery(false);
  };

  return (
    <div style={{ padding: '20px', border: '1px solid #ccc', margin: '20px 0', borderRadius: '5px' }}>
      <h2>GraphQL Error Demo</h2>

      {fetching && <p>Loading GraphQL query...</p>}

      {error && (
        <div style={{ color: 'red', padding: '10px', backgroundColor: '#ffeeee', borderRadius: '5px' }}>
          <h3>GraphQL Error:</h3>
          <pre>{JSON.stringify(error, null, 2)}</pre>
        </div>
      )}

      {data && !error && (
        <div style={{ color: 'green', padding: '10px', backgroundColor: '#eeffee', borderRadius: '5px' }}>
          <h3>Query Success:</h3>
          <pre>{JSON.stringify(data, null, 2)}</pre>
        </div>
      )}

      <div style={{ marginTop: '20px' }}>
        <button
          onClick={triggerGraphQLError}
          disabled={useInvalidQuery || autoTrigger}
          style={{ marginRight: '10px' }}
        >
          Trigger GraphQL Error
        </button>
        <button onClick={resetQuery} disabled={!useInvalidQuery || autoTrigger} style={{ marginRight: '10px' }}>
          Reset Query
        </button>
        <button
          onClick={() => setAutoTrigger(!autoTrigger)}
          style={{ backgroundColor: autoTrigger ? '#ff4444' : '#44ff44', color: 'black' }}
        >
          {autoTrigger ? 'Stop Auto-Trigger' : 'Start Auto-Trigger'}
        </button>
      </div>

      <p style={{ marginTop: '10px', fontSize: '14px', color: '#666' }}>
        Current query: {useInvalidQuery ? 'INVALID (will error)' : 'VALID (will succeed)'}
        {autoTrigger && ' | Auto-trigger: ENABLED (every 5s)'}
      </p>
    </div>
  );
}

export default GraphQLDemo;
