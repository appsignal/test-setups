import time
import os

import appsignal

from opentelemetry import trace

import redis
from celery import Celery
from celery.signals import worker_process_init


@worker_process_init.connect(weak=False)
def init_celery_tracing(*args, **kwargs):
    os.environ["OTEL_SERVICE_NAME"] = "celery-app"
    # appsignal.start()


app = Celery('tasks', broker='redis://redis')
app.conf.task_routes = {
    'tasks.performance_task': { 'queue': 'low-priority' },
    'tasks.performance_task2': { 'queue': 'low-priority' },
    'tasks.error_task': { 'queue': 'high-priority' }
}


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
