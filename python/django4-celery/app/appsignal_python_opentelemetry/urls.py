"""appsignal_python_opentelemetry URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path

from . import views

urlpatterns = [
    path('admin', admin.site.urls),
    path('', views.home, name='home'),
    path('test', views.home, name='test'),
    path('slow', views.slow, name='slow'),
    path('slow_queue', views.slow_queue, name='slow_queue'),
    path('slow_queue_inline', views.slow_queue_inline, name='slow_queue_inline'),
    path('error', views.error, name='error'),
    path('error_queue', views.error_queue, name='error_queue'),
    path('error_queue_inline', views.error_queue_inline, name='error_queue_inline'),
    path('make_request', views.make_request, name='make_request'),
    path('custom_instrumentation', views.custom_instrumentation, name='custom_instrumentation'),
    path('blog', include("blog.urls"))
]
