import requests
import json
import time

from opentelemetry import trace

from django.http import HttpResponse
from django.shortcuts import render

from tasks import error_task, performance_task, performance_task2

from appsignal import (
    set_namespace,
    set_header,
    set_session_data,
    set_tag,
    set_custom_data,
    set_params,
    set_root_name,
    set_category,
    set_name,
    set_body
)


def home(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("something.custom"):
        set_tag("custom1", "tag test")
        set_category("something.custom")
        set_name("Span name")
        set_body("Span body")
        set_session_data({
            "secret": "pw",
            "foo": "bar"
        })
    return render(request, 'home.html', {})


def remote(request):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("remote.request"):
        requests.get("http://app_child:4002/")

    return HttpResponse("I made a request to a microservice")
