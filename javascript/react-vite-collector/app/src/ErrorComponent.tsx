import { BaseOpenTelemetryComponent } from '@opentelemetry/plugin-react-load';

export class ErrorComponent extends BaseOpenTelemetryComponent {
  render() {
    throw new Error('This is a test error!');
    return <div>You will never see this</div>;
  }
}
