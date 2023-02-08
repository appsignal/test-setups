import json
import subprocess
import os

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

from opentelemetry.instrumentation.celery import CeleryInstrumentor
from opentelemetry.instrumentation.django import DjangoInstrumentor
from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor
from opentelemetry.instrumentation.jinja2 import Jinja2Instrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor


attributes = {
    "service.name": "appsignal_python_opentelemetry",
    "appsignal.config.language_integration": "python",
    "appsignal.config.app_path": os.path.dirname(__file__),
}
try:
    revision = subprocess.check_output("git log --pretty=format:'%h' -n 1", shell=True).strip()
    attributes["appsignal.config.revision"] = revision
except subprocess.CalledProcessError:
    pass

resource = Resource(attributes=attributes)

provider = TracerProvider(resource=resource)
console_processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(console_processor)

otlp_exporter = OTLPSpanExporter(endpoint="http://appsignal:8099")
exporter_processor = BatchSpanProcessor(otlp_exporter)
provider.add_span_processor(exporter_processor)

trace.set_tracer_provider(provider)

def response_hook(span, request, response):
    span.set_attribute(
        'appsignal.request.parameters',
        json.dumps({
            "GET": request.GET,
            "POST": request.POST
        })
    )
    pass

def add_instrumentation():
    RequestsInstrumentor().instrument()
    DjangoInstrumentor().instrument(response_hook=response_hook)
    Jinja2Instrumentor().instrument()
    Psycopg2Instrumentor().instrument(enable_commenter=True, commenter_options={})
    RedisInstrumentor().instrument(sanitize_query=True)
    CeleryInstrumentor().instrument()
