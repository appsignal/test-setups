from __appsignal__ import appsignal
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

appsignal.start()

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
async def root():
    return """
      <h1>Python FastAPI OpenTelemetry app</h1>

      <ul>
        <li><a href="/slow">/slow: Trigger a slow request</a></li>
        <li><a href="/error">/error: Trigger an error</a></li>
        <li><a href="/hello/world">/hello/{name}: Use parameterised routing</a></li>
      </ul>
    """

@app.get("/slow")
async def slow():
    import time
    time.sleep(2)
    return {"wow_that_took": "forever"}

@app.get("/error")
async def error():
    raise Exception("I am an error!")

@app.get("/hello/{name}")
async def hello(name):
    return {"greeting": f"Hello, {name}!"}


FastAPIInstrumentor.instrument_app(app)
