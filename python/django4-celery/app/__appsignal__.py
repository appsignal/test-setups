from appsignal import Appsignal

appsignal = Appsignal(
    active=True,
    environment="development",
    log_level="trace",
)
