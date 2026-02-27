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

  const [result] = useQuery({
    query: useInvalidQuery ? INVALID_QUERY : VALID_QUERY,
  });

  const { data, fetching, error } = result;

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
          disabled={useInvalidQuery}
          style={{ marginRight: '10px' }}
        >
          Trigger GraphQL Error
        </button>
        <button onClick={resetQuery} disabled={!useInvalidQuery}>
          Reset Query
        </button>
      </div>

      <p style={{ marginTop: '10px', fontSize: '14px', color: '#666' }}>
        Current query: {useInvalidQuery ? 'INVALID (will error)' : 'VALID (will succeed)'}
      </p>
    </div>
  );
}

export default GraphQLDemo;
