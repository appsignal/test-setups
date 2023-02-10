import requests
import json
import time

from opentelemetry import trace

from django.http import HttpResponse
from django.shortcuts import render

from tasks import error_task, performance_task, performance_task2

def home(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom") as span:
        span.set_attribute("appsignal.category", "something.custom")
        span.set_attribute(
            "appsignal.request.session_data",
            json.dumps({
                "secret": "pw",
                "foo": "bar"
            })
        )
    return render(request, 'home.html', {})

def slow(request):
    time.sleep(1)
    return HttpResponse("I was slow!")

def slow_queue(request):
    performance_task.delay("argument 1", "argument 2")
    performance_task2.delay("argument 3", "argument 4")
    return HttpResponse("I queued an performance_task!")

def slow_queue_inline(request):
    performance_task.apply(["argument 1", "argument 2"])
    return HttpResponse("I ran an performance_task inline!")

def error(request):
    raise Exception("I am an error!")

def error_queue(request):
    error_task.delay()
    return HttpResponse("I queued an error_task!")

def error_queue_inline(request):
    error_task.apply()
    return HttpResponse("I ran an error_task inline!")

def make_request(request):
    requests.get('https://www.appsignal.com/')
    return HttpResponse("I did a request to appsignal.com!")

def custom_instrumentation(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("sleep.time") as span:
        span.set_attribute("appsignal.category", "sleep.time")
        time.sleep(0.1)
        with tracer.start_as_current_span("sleep.time") as span:
            span.set_attribute("appsignal.category", "sleep.time")
            time.sleep(0.2)
    return HttpResponse("I reported some custom instrumentation!")
