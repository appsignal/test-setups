# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/slow")
def slow():
    import time
    time.sleep(2)
    return "<p>Wow, that took forever</p>"

@app.route("/error")
def error():
    raise Exception("I am an error!")
