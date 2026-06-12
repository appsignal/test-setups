from django.db import models

class Post(models.Model):
    title = models.CharField(max_length=30)
    body = models.CharField(max_length=10000)
