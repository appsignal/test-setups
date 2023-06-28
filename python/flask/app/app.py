# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from flask import Flask
app = Flask(__name__)

from opentelemetry import metrics

meter = metrics.get_meter("flask-app-custom-metrics")

request_counter = meter.create_counter(
    "request.count", unit="1", description="Counts the amount of requests received"
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
  request_counter.add(1)
  return "<p>Emitted some custom metrics!</p>"
