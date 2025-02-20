import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import { Counter } from './Counter'
import { ErrorBoundary } from './ErrorBoundary'
import { ErrorComponent } from './ErrorComponent'
import { BaseOpenTelemetryComponent } from '@opentelemetry/plugin-react-load';

class App extends BaseOpenTelemetryComponent {
  render() {
    return (
      <>
        <div>
          <a href="https://vite.dev" target="_blank">
            <img src={viteLogo} className="logo" alt="Vite logo" />
          </a>
          <a href="https://react.dev" target="_blank">
            <img src={reactLogo} className="logo react" alt="React logo" />
          </a>
        </div>
        <h1>Vite + React</h1>
        <Counter />
        <ErrorBoundary>
          <ErrorComponent />
        </ErrorBoundary>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
        <p className="read-the-docs">
          Click on the Vite and React logos to learn more
        </p>
      </>
    );
  }
}

export default App;
