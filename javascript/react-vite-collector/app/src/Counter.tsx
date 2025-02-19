import "./Counter.css"
import { BaseOpenTelemetryComponent } from '@opentelemetry/plugin-react-load';

export class Counter extends BaseOpenTelemetryComponent {
  state = {
    count: 0
  };

  setCount = (updater: (count: number) => number) => {
    this.setState({ count: updater(this.state.count) });
  };

  render() {
    return (
      <div className="card">
        <button onClick={() => this.setCount((count) => count + 1)}>
          count is {this.state.count}
        </button>
      </div>
    );
  }
}
