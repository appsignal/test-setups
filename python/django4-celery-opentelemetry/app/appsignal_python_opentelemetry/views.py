import requests
import json
import time
from random import randrange

from opentelemetry import trace

from django.http import HttpResponse
from django.shortcuts import render

from tasks import error_task, performance_task, performance_task2


def home(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom"):
        # Do something
        tracer
    return render(request, 'home.html', {})


def custom(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom"):
        # Do something
        tracer
    return HttpResponse("Custom route")


def slow(request):
    time.sleep(3)
    return HttpResponse("I was slow!")


def slow_queue(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("queue.task"):
        performance_task.delay("argument 1", "argument 2")

    with tracer.start_as_current_span("queue.task"):
        performance_task2.delay("argument 3", "argument 4")
    return HttpResponse("I queued an performance_task!")


def slow_queue_inline(request):
    performance_task.apply(["argument 1", "argument 2"])
    return HttpResponse("I ran an performance_task inline!")


def error(request):
    raise Exception("I am an error!")


def custom_error(request):
    raise MyException("I am a custom error!")


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
    with tracer.start_as_current_span("sleep.time"):
        time.sleep(0.1)
        with tracer.start_as_current_span("sleep.time"):
            time.sleep(0.2)
    return HttpResponse("I reported some custom instrumentation!")


def metrics(request):
    # Not implemented yet
    return HttpResponse("I reported some metrics instrumentation!")


class MyException(Exception):
    pass
