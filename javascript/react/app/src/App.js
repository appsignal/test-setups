import logo from './logo.svg';
import './App.css';
import appsignal from "./Appsignal";
import { ErrorBoundary } from "@appsignal/react";
import { useState } from "react";
import { Provider as UrqlProvider } from 'urql';
import { client } from './graphqlClient';
import GraphQLDemo from './GraphQLDemo';

const FallbackComponent = () => (
  <div>Uh oh! There was an error :(</div>
);

function AppWrapper() {
  return (
    <UrqlProvider value={client}>
      <ErrorBoundary
        instance={appsignal}
        tags={{ tag: "value" }}
        fallback={(error) => <FallbackComponent />}
      >
        <App />
      </ErrorBoundary>
    </UrqlProvider>
  );
}

function App() {
  const [withError, setWithError] = useState(false);
  const triggerError = () => {
    setWithError(true);
  }
  if (withError) {
    // Throw error in render function, rather than the `triggerError` event
    // handler. Errors in event handlers are not picked up by the
    // ErrorBoundary.
    throw new Error("I crashed the page")
  }

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Welcome to the React test app!
        </p>
        <GraphQLDemo />
        <p><button onClick={triggerError}>Trigger error</button></p>
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default AppWrapper;
