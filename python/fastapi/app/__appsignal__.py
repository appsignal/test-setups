from appsignal import Appsignal

appsignal = Appsignal(
    active=True,
    name="python/fastapi",
    environment="development",
    log_level="trace",
)
