# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from flask import Flask
app = Flask(__name__)

from typing import Iterable
from opentelemetry import metrics
from opentelemetry.metrics import Observation, CallbackOptions

from random import randrange

meter = metrics.get_meter("flask-app-custom-metrics")

monotonic_counter_with_tags = meter.create_counter(
    "monotonic_counter_with_tags",
    unit="1",
    description="monotonic counter with tags"
)
monotonic_counter = meter.create_counter(
    "monotonic_counter", unit="1", description="monotonic counter"
)
non_monotonic_counter = meter.create_up_down_counter(
    "non_monotonic_counter",
    unit="1",
    description="non monotonic counter"
)


def gauge_callback(options: CallbackOptions) -> Iterable[Observation]:
    return [Observation(100 + randrange(50))]


meter.create_observable_gauge(
    "some_gauge",
    callbacks=[gauge_callback],
    unit="1",
    description="test gauge"
)

@app.route("/")
def home():
    return """
      <h1>Python Flask OpenTelemetry app</h1>

      <ul>
        <li><a href="/slow">/slow: Trigger a slow request</a></li>
        <li><a href="/error">/error: Trigger an error</a></li>
        <li><a href="/hello/world">/hello/&lt;name&gt;: Use parameterised routing</a></li>
        <li><a href="/metrics">/metrics: Emit custom metrics</a></li>
      </ul>
    """

@app.route("/slow")
def slow():
    import time
    time.sleep(2)
    return "<p>Wow, that took forever</p>"

@app.route("/error")
def error():
    raise Exception("I am an error!")

@app.route("/hello/<name>")
def hello(name):
    return f"<p>Hello, {name}!"

@app.route("/metrics")
def metrics():
    monotonic_counter_with_tags.add(1, {"tag1": "value1", "tag2": "value2"})
    monotonic_counter.add(1)
    non_monotonic_counter.add(10)
    non_monotonic_counter.add(-5)
    return "<p>Emitted some custom metrics!</p>"
