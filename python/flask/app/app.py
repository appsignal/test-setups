# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return """
      <h1>Python Flask OpenTelemetry app</h1>

      <ul>
        <li><a href="/slow">/slow: Trigger a slow request</a></li>
        <li><a href="/error">/error: Trigger an error</a></li>
        <li><a href="/hello/world">/hello/&lt;name&gt;: Use parameterised routing</a></li>
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
