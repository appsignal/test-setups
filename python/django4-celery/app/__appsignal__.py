from appsignal import Appsignal

appsignal = Appsignal(
    active=True,
    name="python/django4-celery",
    environment="development",
)
