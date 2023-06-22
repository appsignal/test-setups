from appsignal import Appsignal

appsignal = Appsignal(
    active=True,
    name="python/starlette",
    environment="development",
    log_level="trace",
)
