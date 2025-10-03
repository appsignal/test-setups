import requests
import json
import time
from random import randrange
import datetime

from opentelemetry import trace
from opentelemetry.metrics import get_meter

from django.http import HttpResponse
from django.shortcuts import render

from tasks import error_task, performance_task, performance_task2


def home(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom") as span:
        span.set_attribute("appsignal.request.query_parameters", json.dumps({
            "password": "super secret",
            "email": "test@example.com",
            "cvv": 123,
            "test_param": "test value",
            "nested": {
                "password": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.request.payload", json.dumps({
            "password": "super secret",
            "email": "test@example.com",
            "cvv": 123,
            "test_param": "test value",
            "nested": {
                "password": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.request.session_data", json.dumps({
            "token": "super secret",
            "user_id": 123,
            "test_param": "test value",
            "nested": {
                "token": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.function.parameters", json.dumps({
            "hash": "super secret",
            "salt": "shoppai",
            "test_param": "test value",
            "nested": {
                "hash": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("http.request.header.content-type",
                           ["application/json"])
        span.set_attribute("http.request.header.custom-header", ["abc", "def"])
        span.set_attribute("db.statement", "SELECT * FROM foo")
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
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom") as span:
        span.set_attribute("appsignal.request.query_parameters", json.dumps({
            "password": "super secret",
            "email": "test@example.com",
            "cvv": 123,
            "test_param": "test value",
            "nested": {
                "password": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.request.payload", json.dumps({
            "password": "super secret",
            "email": "test@example.com",
            "cvv": 123,
            "test_param": "test value",
            "nested": {
                "password": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.request.session_data", json.dumps({
            "token": "super secret",
            "user_id": 123,
            "test_param": "test value",
            "nested": {
                "token": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("appsignal.function.parameters", json.dumps({
            "hash": "super secret",
            "salt": "shoppai",
            "test_param": "test value",
            "nested": {
                "hash": "super secret nested",
                "test_param": "test value",
            }
        }))
        span.set_attribute("http.request.header.content-type",
                           ["application/json"])
        span.set_attribute("http.request.header.custom-header", ["abc", "def"])
        span.set_attribute("db.statement", "SELECT * FROM foo")
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
    meter = get_meter("my_meter")

    # Counter
    my_counter = meter.create_counter(
        "my_counter",
        unit="1",
        description="My counter"
    )
    count_value = randrange(1, 3)
    my_counter.add(count_value, {"my_tag": "tag_value"})

    # Gauge
    my_gauge = meter.create_gauge(
        "my_gauge",
        unit="1",
        description="My gauge"
    )
    gauge_value = randrange(1, 25)
    my_gauge.set(gauge_value, {"my_tag": "tag_value"})

    # Histogram
    histogram = meter.create_histogram(
        "my_histogram",
        unit="1",
        description="My histogram"
    )
    histogram_value = randrange(10, 25)
    histogram.record(histogram_value, {"my_tag": "tag_value"})

    time = datetime.datetime.now()
    return HttpResponse(
        f"{time}: Reported metrics: Counter: {count_value}, " +
        f"Gauge: {gauge_value}, Histogram: {histogram_value}\n"
    )


class MyException(Exception):
    pass
