import logo from './logo.svg';
import './App.css';
import appsignal from "./Appsignal";
import { ErrorBoundary } from "@appsignal/react";


const FallbackComponent = () => (
  <div>Uh oh! There was an error :(</div>
);

function AppWrapper() {
  return (
    <ErrorBoundary
      instance={appsignal}
      tags={{ tag: "value" }}
      fallback={(error) => <FallbackComponent />}
    >
      <App />
    </ErrorBoundary>
  );
}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Welcome to the React test app!
        </p>
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
