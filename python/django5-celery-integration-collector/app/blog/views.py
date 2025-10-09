import redis

from django.shortcuts import render

from blog.models import Post

def index(request):
    posts = Post.objects.all()
    r = redis.Redis(host='redis', port=6379, db=0)
    r.set('some_key', 'some_value')
    redis_value = r.get('some_key')
    context = { 'posts': posts, 'redis_value': redis_value }
    return render(request, 'index.html', context)

def show(request):
    post = Post.objects.get(id=request.GET['id'])
    context = { 'post': post }
    return render(request, 'show.html', context)

def create(request):
    post = Post(title="Hello world!", body="I am the long form greeting! Hi!")
    post.save()
    context = { 'post': post }
    return render(request, 'show.html', context)
