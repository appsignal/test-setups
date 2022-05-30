const { appsignal } = require("./appsignal");
const { SpanProcessor } = require("@appsignal/nodejs");
const opentelemetrySdk = require("@opentelemetry/sdk-node");
const opentelemetry = require("@opentelemetry/api");
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { MySQLInstrumentation } = require('@opentelemetry/instrumentation-mysql');
const { MySQL2Instrumentation } = require('@opentelemetry/instrumentation-mysql2');
const { RedisInstrumentation } = require('@opentelemetry/instrumentation-redis');
const { IORedisInstrumentation } = require('@opentelemetry/instrumentation-ioredis');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');

const sdk = new opentelemetrySdk.NodeSDK({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    MySQLInstrumentation,
    MySQL2Instrumentation,
    RedisInstrumentation,
    new IORedisInstrumentation({ requireParentSpan: false })
  ]
});

sdk.start()

const tracerProvider = new NodeTracerProvider();
tracerProvider.addSpanProcessor(new SpanProcessor(appsignal));

class ConsoleSpanProcessor {
  forceFlush() {
    return Promise.resolve()
  }

  onStart(_span, _parentContext) {
    // Does nothing
  }

  onEnd(span) {
    console.log("OpenTelemetry Span:", span)
  }

  shutdown() {
    // Does nothing
    return Promise.resolve()
  }
}
tracerProvider.addSpanProcessor(new ConsoleSpanProcessor);

tracerProvider.register();

const tracer = opentelemetry.trace.getTracer("node-tracer");

module.exports = { tracer };
