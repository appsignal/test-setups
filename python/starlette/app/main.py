from __appsignal__ import appsignal
from starlette.applications import Starlette
from starlette.responses import HTMLResponse, JSONResponse
from starlette.routing import Route

from opentelemetry.instrumentation.starlette import StarletteInstrumentor

appsignal.start()

async def root(request):
    return HTMLResponse("""
      <h1>Python Starlette OpenTelemetry app</h1>

      <ul>
        <li><a href="/slow">/slow: Trigger a slow request</a></li>
        <li><a href="/error">/error: Trigger an error</a></li>
        <li><a href="/hello/world">/hello/{name}: Use parameterised routing</a></li>
      </ul>
    """)

async def slow(request):
    import time
    time.sleep(2)
    return JSONResponse({"wow_that_took": "forever"})

async def error(request):
    raise Exception("I am an error!")

async def hello(request):
    return JSONResponse({"greeting": f"Hello, {request.path_params['name']}!"})

app = Starlette(routes=[
    Route('/', root),
    Route('/slow', slow),
    Route('/error', error),
    Route('/hello/{name}', hello),
])

StarletteInstrumentor.instrument_app(app)
