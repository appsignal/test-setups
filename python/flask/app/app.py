# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from appsignal import (
    set_params,
    set_custom_data,
    set_tag,
    set_root_name,
    send_error,
    set_gauge,
    increment_counter,
)

from flask import Flask, request
app = Flask(__name__)

from random import randrange

@app.route("/")
def home():
    return """
        <h1>Python Flask OpenTelemetry app</h1>

        <ul>
        <li><a href="/slow"><kbd>/slow</kbd> &rarr; Trigger a slow request</a></li>
        <li><a href="/error"><kbd>/error</kbd> &rarr; Trigger an error (and use error helpers)</a></li>
        <li><a href="/error/nested"><kbd>/error</kbd> &rarr; Trigger a nested error (an error raised while handling another error)</a></li>
        <li><a href="/hello/world"><kbd>/hello/&lt;name&gt;</kbd> &rarr; Use parameterised routing</a></li>
        <li><a href="/metrics"><kbd>/metrics</kbd> &rarr; Emit custom metrics</a></li>
        <li><a href="/custom"><kbd>/custom</kbd> &rarr; Use sample data helpers (send a POST request with JSON for params!)</a></li>
        </ul>
    """

@app.route("/slow")
def slow():
    import time
    time.sleep(2)
    return "<p>Wow, that took forever</p>"

@app.route("/error")
def error():
    class ManuallyHandledError(Exception):
        pass

    class AutomaticallyHandledError(Exception):
        pass

    try:
        raise ManuallyHandledError("I am an error sent manually using send_error!")
    except ManuallyHandledError as error:
        send_error(error)

    raise AutomaticallyHandledError("I am an error reported automatically by the Flask instrumentation!")

@app.route("/error/nested")
def nested_error():
    class RootError(Exception):
        pass

    class DerivedError(Exception):
        pass

    def raise_root_error():
        raise RootError("I am the root error!")

    def raise_derived_error():
        try: 
            raise_root_error()
        except RootError:
            raise DerivedError("I am the derived error!")
            
    raise_derived_error()

@app.route("/hello/<name>")
def hello(name):
    return f"<p>Hello, {name}!"

@app.route("/metrics")
def metrics():
    increment_counter("some_counter", 1)
    increment_counter("some_negative_counter", -1)
    increment_counter("some_counter_with_tags", 1, {"tag1": "value1", "tag2": "value2"})
    set_gauge("some_gauge", randrange(1, 100))
    set_gauge("some_gauge_with_tags", randrange(1, 100), {"tag1": "value1", "tag2": "value2"})

    return "<p>Emitted some custom metrics!</p>"

@app.route("/custom", methods=["GET", "POST"])
def custom():
    if request.method == "POST":
        set_params(request.json or {})

    set_custom_data({"hello": "there"})
    set_tag("custom", True)
    set_root_name("Custom endpoint")

    return "<p>Sent custom endpoint data!</p>"
