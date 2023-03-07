from django.contrib import admin
from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('post/', views.show, name='show'),
    path('create/', views.create, name='create'),
]
