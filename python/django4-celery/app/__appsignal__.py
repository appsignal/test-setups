import os
import subprocess
from appsignal import Appsignal

app_env = os.environ.get("MY_APP_ENV")
revision = subprocess \
    .run(["git", "log", "--pretty=format:%h", "-n 1"], stdout=subprocess.PIPE) \
    .stdout \
    .decode("utf-8")

options = {
    "active": app_env == "development",
    "name": "python/django4-celery",
    "environment": app_env,
    "revision": revision,
    "disable_default_instrumentations": ["opentelemetry.instrumentation.requests"]
}

appsignal = Appsignal(**options)
