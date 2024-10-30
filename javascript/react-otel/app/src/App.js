import logo from './logo.svg';
import './App.css';
import React, { useState, useContext } from "react";
import { SpanStatusCode } from "@opentelemetry/api";
import { initializeTracing } from "./opentelemetry";

const tracer = initializeTracing();
console.log(tracer)
export const TracerContext = React.createContext(tracer);

function App() {
  const tracer = useContext(TracerContext);
  const [withError, setWithError] = useState(false);

  const triggerError = () => {
    const span = tracer.startSpan("testError");

    try {
      setWithError(true);
      span.setAttributes({
        "error.intentional": true
      });
    } catch (error) {
      span.recordException(error);
      span.setStatus({ code: SpanStatusCode.ERROR });
      throw error;
    } finally {
      span.end();
    }
  }

  if (withError) {
    const span = tracer.startSpan("renderError");
    const error = new Error("Page render error");
    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR });
    span.end();
    throw error;
  }

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Welcome to the React test app!
        </p>
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

function AppWrapper() {
  return (
    <TracerContext.Provider value={tracer}>
      <App />
    </TracerContext.Provider>
  );
}

export default AppWrapper;
