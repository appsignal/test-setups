from appsignal import Appsignal

appsignal = Appsignal(
    name="python/django4-celery",
    environment="development",
    log_level="trace",
)
