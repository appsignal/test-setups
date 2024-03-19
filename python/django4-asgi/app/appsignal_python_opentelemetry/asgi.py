"""
ASGI config for appsignal_python_opentelemetry project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/asgi/
"""

import os
import appsignal

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'appsignal_python_opentelemetry.settings')
appsignal.start()

application = get_asgi_application()
