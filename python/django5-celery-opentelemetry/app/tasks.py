import time
import os

from opentelemetry import trace

import redis
from celery import Celery
from celery.signals import worker_process_init
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.celery import CeleryInstrumentor


@worker_process_init.connect(weak=False)
def init_celery_tracing(*args, **kwargs):
    # Do something?
    args


app = Celery('tasks', broker='redis://redis')
app.conf.task_routes = {
    'tasks.performance_task': { 'queue': 'low-priority' },
    'tasks.performance_task2': { 'queue': 'low-priority' },
    'tasks.error_task': { 'queue': 'high-priority' }
}

# Add AppSignal and app configuration
resource = Resource(attributes={
    "appsignal.config.app_name": os.environ.get("APPSIGNAL_APP_NAME") or "",
    "appsignal.config.app_environment": os.environ.get("APPSIGNAL_APP_ENV") or "",
    "appsignal.config.push_api_key": os.environ.get("APPSIGNAL_PUSH_API_KEY") or "",
    # "appsignal.config.revision": revision,
    "appsignal.config.language_integration": "python",
    "appsignal.config.app_path": os.getcwd(),
    # Customize the service name
    "service.name": "Django",
})
provider = TracerProvider(resource=resource)

# Configure the OpenTelemetry HTTP exporter
span_processor = BatchSpanProcessor(OTLPSpanExporter(endpoint="http://appsignal-agent:8099/enriched/v1/traces"))
provider.add_span_processor(span_processor)
trace.set_tracer_provider(provider)

CeleryInstrumentor().instrument()


@app.task
def performance_task(argument1, argument2):
    r = redis.Redis(host='redis', port=6379, db=0)
    r.set('some_key', 'some_value')
    redis_value = r.get('some_key')
    time.sleep(0.2)


@app.task
def performance_task2(argument1, argument2):
    r = redis.Redis(host='redis', port=6379, db=0)
    r.set('some_key2', 'some_value2')
    redis_value = r.get('some_key2')
    time.sleep(0.2)

@app.task
def error_task():
    raise Exception("Celery error")
