# Test setups

<!-- Generated from support/templates/README.md.erb -->

Run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

Generate an environment file using a valid push api key you
can get on [AppSignal](https://appsignal.com):

```
rake global:set_push_api_key key=<key>
```

To start a test setup:

```
rake app=elixir/alpine-release app:up
rake app=elixir/phoenix app:up
rake app=elixir/phoenix-collector app:up
rake app=elixir/phoenix-oban app:up
rake app=elixir/plug app:up
rake app=elixir/plug-ecto app:up
rake app=elixir/plug-oban app:up
rake app=elixir/single-task app:up
rake app=go/beego app:up
rake app=go/beego-mod-otel app:up
rake app=go/go-gin-mysql app:up
rake app=go/go-gin-mysql-collector app:up
rake app=go/gorilla-mux-mysql-redis-mongo app:up
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:up
rake app=java/spring-agent-collector app:up
rake app=java/spring-native-collector app:up
rake app=javascript/Dockerfile app:up
rake app=javascript/ember app:up
rake app=javascript/react app:up
rake app=javascript/react-vite-collector app:up
rake app=javascript/typescript-angular app:up
rake app=javascript/vanilla app:up
rake app=javascript/vue-3 app:up
rake app=javascript/webpack app:up
rake app=nodejs/express-apollo app:up
rake app=nodejs/express-bullmq app:up
rake app=nodejs/express-elasticsearch app:up
rake app=nodejs/express-mongoose app:up
rake app=nodejs/express-postgres app:up
rake app=nodejs/express-postgres-collector app:up
rake app=nodejs/express-rabbitmq app:up
rake app=nodejs/express-redis app:up
rake app=nodejs/express-redis-alpine app:up
rake app=nodejs/express-yoga app:up
rake app=nodejs/fastify app:up
rake app=nodejs/koa-microservices app:up
rake app=nodejs/koa-mongo app:up
rake app=nodejs/koa-mysql app:up
rake app=nodejs/nestjs app:up
rake app=nodejs/nestjs-10 app:up
rake app=nodejs/nestjs-prisma app:up
rake app=nodejs/nextjs-13-app app:up
rake app=nodejs/nextjs-14-app app:up
rake app=nodejs/nextjs-14-pages app:up
rake app=nodejs/nextjs-15-app-collector app:up
rake app=nodejs/remix app:up
rake app=nodejs/restify app:up
rake app=php/laravel-collector app:up
rake app=php/symfony-collector app:up
rake app=php/vanilla-collector app:up
rake app=python/django4-asgi app:up
rake app=python/django4-celery app:up
rake app=python/django4-wsgi app:up
rake app=python/django5-celery app:up
rake app=python/django5-celery-collector app:up
rake app=python/django5-celery-integration-collector app:up
rake app=python/fastapi app:up
rake app=python/fastapi-databases app:up
rake app=python/flask app:up
rake app=python/flask-pika app:up
rake app=python/flask-sqlalchemy app:up
rake app=python/starlette app:up
rake app=ruby/grape app:up
rake app=ruby/hanami2-postgres app:up
rake app=ruby/jruby-rails6 app:up
rake app=ruby/jruby-single-task app:up
rake app=ruby/linux-arm app:up
rake app=ruby/padrino app:up
rake app=ruby/rack app:up
rake app=ruby/rails6-mongo app:up
rake app=ruby/rails6-mysql app:up
rake app=ruby/rails6-shakapacker app:up
rake app=ruby/rails6-shoryuken app:up
rake app=ruby/rails7-delayed-job app:up
rake app=ruby/rails7-goodjob app:up
rake app=ruby/rails7-postgres app:up
rake app=ruby/rails7-sequel app:up
rake app=ruby/rails7-sidekiq app:up
rake app=ruby/rails7-solid-cache app:up
rake app=ruby/rails7-solid-queue app:up
rake app=ruby/rails8-sidekiq app:up
rake app=ruby/rails8-sidekiq-collector app:up
rake app=ruby/shoryuken app:up
rake app=ruby/sinatra-alpine app:up
rake app=ruby/sinatra-gvltools app:up
rake app=ruby/sinatra-puma app:up
rake app=ruby/sinatra-redis app:up
rake app=ruby/single-task app:up
rake app=ruby/webmachine1 app:up
rake app=ruby/webmachine2 app:up
rake app=standalone/nginx app:up
rake app=vector/mongodb app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:4001). The agent log and lock files are
accessible in the `working_directory`.

To restart the app container after making changes to an integration:

```
rake app=elixir/alpine-release app:restart
rake app=elixir/phoenix app:restart
rake app=elixir/phoenix-collector app:restart
rake app=elixir/phoenix-oban app:restart
rake app=elixir/plug app:restart
rake app=elixir/plug-ecto app:restart
rake app=elixir/plug-oban app:restart
rake app=elixir/single-task app:restart
rake app=go/beego app:restart
rake app=go/beego-mod-otel app:restart
rake app=go/go-gin-mysql app:restart
rake app=go/go-gin-mysql-collector app:restart
rake app=go/gorilla-mux-mysql-redis-mongo app:restart
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:restart
rake app=java/spring-agent-collector app:restart
rake app=java/spring-native-collector app:restart
rake app=javascript/Dockerfile app:restart
rake app=javascript/ember app:restart
rake app=javascript/react app:restart
rake app=javascript/react-vite-collector app:restart
rake app=javascript/typescript-angular app:restart
rake app=javascript/vanilla app:restart
rake app=javascript/vue-3 app:restart
rake app=javascript/webpack app:restart
rake app=nodejs/express-apollo app:restart
rake app=nodejs/express-bullmq app:restart
rake app=nodejs/express-elasticsearch app:restart
rake app=nodejs/express-mongoose app:restart
rake app=nodejs/express-postgres app:restart
rake app=nodejs/express-postgres-collector app:restart
rake app=nodejs/express-rabbitmq app:restart
rake app=nodejs/express-redis app:restart
rake app=nodejs/express-redis-alpine app:restart
rake app=nodejs/express-yoga app:restart
rake app=nodejs/fastify app:restart
rake app=nodejs/koa-microservices app:restart
rake app=nodejs/koa-mongo app:restart
rake app=nodejs/koa-mysql app:restart
rake app=nodejs/nestjs app:restart
rake app=nodejs/nestjs-10 app:restart
rake app=nodejs/nestjs-prisma app:restart
rake app=nodejs/nextjs-13-app app:restart
rake app=nodejs/nextjs-14-app app:restart
rake app=nodejs/nextjs-14-pages app:restart
rake app=nodejs/nextjs-15-app-collector app:restart
rake app=nodejs/remix app:restart
rake app=nodejs/restify app:restart
rake app=php/laravel-collector app:restart
rake app=php/symfony-collector app:restart
rake app=php/vanilla-collector app:restart
rake app=python/django4-asgi app:restart
rake app=python/django4-celery app:restart
rake app=python/django4-wsgi app:restart
rake app=python/django5-celery app:restart
rake app=python/django5-celery-collector app:restart
rake app=python/django5-celery-integration-collector app:restart
rake app=python/fastapi app:restart
rake app=python/fastapi-databases app:restart
rake app=python/flask app:restart
rake app=python/flask-pika app:restart
rake app=python/flask-sqlalchemy app:restart
rake app=python/starlette app:restart
rake app=ruby/grape app:restart
rake app=ruby/hanami2-postgres app:restart
rake app=ruby/jruby-rails6 app:restart
rake app=ruby/jruby-single-task app:restart
rake app=ruby/linux-arm app:restart
rake app=ruby/padrino app:restart
rake app=ruby/rack app:restart
rake app=ruby/rails6-mongo app:restart
rake app=ruby/rails6-mysql app:restart
rake app=ruby/rails6-shakapacker app:restart
rake app=ruby/rails6-shoryuken app:restart
rake app=ruby/rails7-delayed-job app:restart
rake app=ruby/rails7-goodjob app:restart
rake app=ruby/rails7-postgres app:restart
rake app=ruby/rails7-sequel app:restart
rake app=ruby/rails7-sidekiq app:restart
rake app=ruby/rails7-solid-cache app:restart
rake app=ruby/rails7-solid-queue app:restart
rake app=ruby/rails8-sidekiq app:restart
rake app=ruby/rails8-sidekiq-collector app:restart
rake app=ruby/shoryuken app:restart
rake app=ruby/sinatra-alpine app:restart
rake app=ruby/sinatra-gvltools app:restart
rake app=ruby/sinatra-puma app:restart
rake app=ruby/sinatra-redis app:restart
rake app=ruby/single-task app:restart
rake app=ruby/webmachine1 app:restart
rake app=ruby/webmachine2 app:restart
rake app=standalone/nginx app:restart
rake app=vector/mongodb app:restart
```

To run bash:

```
rake app=elixir/alpine-release app:bash
rake app=elixir/phoenix app:bash
rake app=elixir/phoenix-collector app:bash
rake app=elixir/phoenix-oban app:bash
rake app=elixir/plug app:bash
rake app=elixir/plug-ecto app:bash
rake app=elixir/plug-oban app:bash
rake app=elixir/single-task app:bash
rake app=go/beego app:bash
rake app=go/beego-mod-otel app:bash
rake app=go/go-gin-mysql app:bash
rake app=go/go-gin-mysql-collector app:bash
rake app=go/gorilla-mux-mysql-redis-mongo app:bash
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:bash
rake app=java/spring-agent-collector app:bash
rake app=java/spring-native-collector app:bash
rake app=javascript/Dockerfile app:bash
rake app=javascript/ember app:bash
rake app=javascript/react app:bash
rake app=javascript/react-vite-collector app:bash
rake app=javascript/typescript-angular app:bash
rake app=javascript/vanilla app:bash
rake app=javascript/vue-3 app:bash
rake app=javascript/webpack app:bash
rake app=nodejs/express-apollo app:bash
rake app=nodejs/express-bullmq app:bash
rake app=nodejs/express-elasticsearch app:bash
rake app=nodejs/express-mongoose app:bash
rake app=nodejs/express-postgres app:bash
rake app=nodejs/express-postgres-collector app:bash
rake app=nodejs/express-rabbitmq app:bash
rake app=nodejs/express-redis app:bash
rake app=nodejs/express-redis-alpine app:bash
rake app=nodejs/express-yoga app:bash
rake app=nodejs/fastify app:bash
rake app=nodejs/koa-microservices app:bash
rake app=nodejs/koa-mongo app:bash
rake app=nodejs/koa-mysql app:bash
rake app=nodejs/nestjs app:bash
rake app=nodejs/nestjs-10 app:bash
rake app=nodejs/nestjs-prisma app:bash
rake app=nodejs/nextjs-13-app app:bash
rake app=nodejs/nextjs-14-app app:bash
rake app=nodejs/nextjs-14-pages app:bash
rake app=nodejs/nextjs-15-app-collector app:bash
rake app=nodejs/remix app:bash
rake app=nodejs/restify app:bash
rake app=php/laravel-collector app:bash
rake app=php/symfony-collector app:bash
rake app=php/vanilla-collector app:bash
rake app=python/django4-asgi app:bash
rake app=python/django4-celery app:bash
rake app=python/django4-wsgi app:bash
rake app=python/django5-celery app:bash
rake app=python/django5-celery-collector app:bash
rake app=python/django5-celery-integration-collector app:bash
rake app=python/fastapi app:bash
rake app=python/fastapi-databases app:bash
rake app=python/flask app:bash
rake app=python/flask-pika app:bash
rake app=python/flask-sqlalchemy app:bash
rake app=python/starlette app:bash
rake app=ruby/grape app:bash
rake app=ruby/hanami2-postgres app:bash
rake app=ruby/jruby-rails6 app:bash
rake app=ruby/jruby-single-task app:bash
rake app=ruby/linux-arm app:bash
rake app=ruby/padrino app:bash
rake app=ruby/rack app:bash
rake app=ruby/rails6-mongo app:bash
rake app=ruby/rails6-mysql app:bash
rake app=ruby/rails6-shakapacker app:bash
rake app=ruby/rails6-shoryuken app:bash
rake app=ruby/rails7-delayed-job app:bash
rake app=ruby/rails7-goodjob app:bash
rake app=ruby/rails7-postgres app:bash
rake app=ruby/rails7-sequel app:bash
rake app=ruby/rails7-sidekiq app:bash
rake app=ruby/rails7-solid-cache app:bash
rake app=ruby/rails7-solid-queue app:bash
rake app=ruby/rails8-sidekiq app:bash
rake app=ruby/rails8-sidekiq-collector app:bash
rake app=ruby/shoryuken app:bash
rake app=ruby/sinatra-alpine app:bash
rake app=ruby/sinatra-gvltools app:bash
rake app=ruby/sinatra-puma app:bash
rake app=ruby/sinatra-redis app:bash
rake app=ruby/single-task app:bash
rake app=ruby/webmachine1 app:bash
rake app=ruby/webmachine2 app:bash
rake app=standalone/nginx app:bash
rake app=vector/mongodb app:bash
```

To run the console (if implemented in the test app):

```
rake app=elixir/alpine-release app:console
rake app=elixir/phoenix app:console
rake app=elixir/phoenix-collector app:console
rake app=elixir/phoenix-oban app:console
rake app=elixir/plug app:console
rake app=elixir/plug-ecto app:console
rake app=elixir/plug-oban app:console
rake app=elixir/single-task app:console
rake app=go/beego app:console
rake app=go/beego-mod-otel app:console
rake app=go/go-gin-mysql app:console
rake app=go/go-gin-mysql-collector app:console
rake app=go/gorilla-mux-mysql-redis-mongo app:console
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:console
rake app=java/spring-agent-collector app:console
rake app=java/spring-native-collector app:console
rake app=javascript/Dockerfile app:console
rake app=javascript/ember app:console
rake app=javascript/react app:console
rake app=javascript/react-vite-collector app:console
rake app=javascript/typescript-angular app:console
rake app=javascript/vanilla app:console
rake app=javascript/vue-3 app:console
rake app=javascript/webpack app:console
rake app=nodejs/express-apollo app:console
rake app=nodejs/express-bullmq app:console
rake app=nodejs/express-elasticsearch app:console
rake app=nodejs/express-mongoose app:console
rake app=nodejs/express-postgres app:console
rake app=nodejs/express-postgres-collector app:console
rake app=nodejs/express-rabbitmq app:console
rake app=nodejs/express-redis app:console
rake app=nodejs/express-redis-alpine app:console
rake app=nodejs/express-yoga app:console
rake app=nodejs/fastify app:console
rake app=nodejs/koa-microservices app:console
rake app=nodejs/koa-mongo app:console
rake app=nodejs/koa-mysql app:console
rake app=nodejs/nestjs app:console
rake app=nodejs/nestjs-10 app:console
rake app=nodejs/nestjs-prisma app:console
rake app=nodejs/nextjs-13-app app:console
rake app=nodejs/nextjs-14-app app:console
rake app=nodejs/nextjs-14-pages app:console
rake app=nodejs/nextjs-15-app-collector app:console
rake app=nodejs/remix app:console
rake app=nodejs/restify app:console
rake app=php/laravel-collector app:console
rake app=php/symfony-collector app:console
rake app=php/vanilla-collector app:console
rake app=python/django4-asgi app:console
rake app=python/django4-celery app:console
rake app=python/django4-wsgi app:console
rake app=python/django5-celery app:console
rake app=python/django5-celery-collector app:console
rake app=python/django5-celery-integration-collector app:console
rake app=python/fastapi app:console
rake app=python/fastapi-databases app:console
rake app=python/flask app:console
rake app=python/flask-pika app:console
rake app=python/flask-sqlalchemy app:console
rake app=python/starlette app:console
rake app=ruby/grape app:console
rake app=ruby/hanami2-postgres app:console
rake app=ruby/jruby-rails6 app:console
rake app=ruby/jruby-single-task app:console
rake app=ruby/linux-arm app:console
rake app=ruby/padrino app:console
rake app=ruby/rack app:console
rake app=ruby/rails6-mongo app:console
rake app=ruby/rails6-mysql app:console
rake app=ruby/rails6-shakapacker app:console
rake app=ruby/rails6-shoryuken app:console
rake app=ruby/rails7-delayed-job app:console
rake app=ruby/rails7-goodjob app:console
rake app=ruby/rails7-postgres app:console
rake app=ruby/rails7-sequel app:console
rake app=ruby/rails7-sidekiq app:console
rake app=ruby/rails7-solid-cache app:console
rake app=ruby/rails7-solid-queue app:console
rake app=ruby/rails8-sidekiq app:console
rake app=ruby/rails8-sidekiq-collector app:console
rake app=ruby/shoryuken app:console
rake app=ruby/sinatra-alpine app:console
rake app=ruby/sinatra-gvltools app:console
rake app=ruby/sinatra-puma app:console
rake app=ruby/sinatra-redis app:console
rake app=ruby/single-task app:console
rake app=ruby/webmachine1 app:console
rake app=ruby/webmachine2 app:console
rake app=standalone/nginx app:console
rake app=vector/mongodb app:console
```

To send in a diagnose (if implemented in the test app);

```
rake app=elixir/alpine-release app:diagnose
rake app=elixir/phoenix app:diagnose
rake app=elixir/phoenix-collector app:diagnose
rake app=elixir/phoenix-oban app:diagnose
rake app=elixir/plug app:diagnose
rake app=elixir/plug-ecto app:diagnose
rake app=elixir/plug-oban app:diagnose
rake app=elixir/single-task app:diagnose
rake app=go/beego app:diagnose
rake app=go/beego-mod-otel app:diagnose
rake app=go/go-gin-mysql app:diagnose
rake app=go/go-gin-mysql-collector app:diagnose
rake app=go/gorilla-mux-mysql-redis-mongo app:diagnose
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:diagnose
rake app=java/spring-agent-collector app:diagnose
rake app=java/spring-native-collector app:diagnose
rake app=javascript/Dockerfile app:diagnose
rake app=javascript/ember app:diagnose
rake app=javascript/react app:diagnose
rake app=javascript/react-vite-collector app:diagnose
rake app=javascript/typescript-angular app:diagnose
rake app=javascript/vanilla app:diagnose
rake app=javascript/vue-3 app:diagnose
rake app=javascript/webpack app:diagnose
rake app=nodejs/express-apollo app:diagnose
rake app=nodejs/express-bullmq app:diagnose
rake app=nodejs/express-elasticsearch app:diagnose
rake app=nodejs/express-mongoose app:diagnose
rake app=nodejs/express-postgres app:diagnose
rake app=nodejs/express-postgres-collector app:diagnose
rake app=nodejs/express-rabbitmq app:diagnose
rake app=nodejs/express-redis app:diagnose
rake app=nodejs/express-redis-alpine app:diagnose
rake app=nodejs/express-yoga app:diagnose
rake app=nodejs/fastify app:diagnose
rake app=nodejs/koa-microservices app:diagnose
rake app=nodejs/koa-mongo app:diagnose
rake app=nodejs/koa-mysql app:diagnose
rake app=nodejs/nestjs app:diagnose
rake app=nodejs/nestjs-10 app:diagnose
rake app=nodejs/nestjs-prisma app:diagnose
rake app=nodejs/nextjs-13-app app:diagnose
rake app=nodejs/nextjs-14-app app:diagnose
rake app=nodejs/nextjs-14-pages app:diagnose
rake app=nodejs/nextjs-15-app-collector app:diagnose
rake app=nodejs/remix app:diagnose
rake app=nodejs/restify app:diagnose
rake app=php/laravel-collector app:diagnose
rake app=php/symfony-collector app:diagnose
rake app=php/vanilla-collector app:diagnose
rake app=python/django4-asgi app:diagnose
rake app=python/django4-celery app:diagnose
rake app=python/django4-wsgi app:diagnose
rake app=python/django5-celery app:diagnose
rake app=python/django5-celery-collector app:diagnose
rake app=python/django5-celery-integration-collector app:diagnose
rake app=python/fastapi app:diagnose
rake app=python/fastapi-databases app:diagnose
rake app=python/flask app:diagnose
rake app=python/flask-pika app:diagnose
rake app=python/flask-sqlalchemy app:diagnose
rake app=python/starlette app:diagnose
rake app=ruby/grape app:diagnose
rake app=ruby/hanami2-postgres app:diagnose
rake app=ruby/jruby-rails6 app:diagnose
rake app=ruby/jruby-single-task app:diagnose
rake app=ruby/linux-arm app:diagnose
rake app=ruby/padrino app:diagnose
rake app=ruby/rack app:diagnose
rake app=ruby/rails6-mongo app:diagnose
rake app=ruby/rails6-mysql app:diagnose
rake app=ruby/rails6-shakapacker app:diagnose
rake app=ruby/rails6-shoryuken app:diagnose
rake app=ruby/rails7-delayed-job app:diagnose
rake app=ruby/rails7-goodjob app:diagnose
rake app=ruby/rails7-postgres app:diagnose
rake app=ruby/rails7-sequel app:diagnose
rake app=ruby/rails7-sidekiq app:diagnose
rake app=ruby/rails7-solid-cache app:diagnose
rake app=ruby/rails7-solid-queue app:diagnose
rake app=ruby/rails8-sidekiq app:diagnose
rake app=ruby/rails8-sidekiq-collector app:diagnose
rake app=ruby/shoryuken app:diagnose
rake app=ruby/sinatra-alpine app:diagnose
rake app=ruby/sinatra-gvltools app:diagnose
rake app=ruby/sinatra-puma app:diagnose
rake app=ruby/sinatra-redis app:diagnose
rake app=ruby/single-task app:diagnose
rake app=ruby/webmachine1 app:diagnose
rake app=ruby/webmachine2 app:diagnose
rake app=standalone/nginx app:diagnose
rake app=vector/mongodb app:diagnose
```

Tail the appsignal log:

```
rake app=elixir/alpine-release app:tail:appsignal
rake app=elixir/phoenix app:tail:appsignal
rake app=elixir/phoenix-collector app:tail:appsignal
rake app=elixir/phoenix-oban app:tail:appsignal
rake app=elixir/plug app:tail:appsignal
rake app=elixir/plug-ecto app:tail:appsignal
rake app=elixir/plug-oban app:tail:appsignal
rake app=elixir/single-task app:tail:appsignal
rake app=go/beego app:tail:appsignal
rake app=go/beego-mod-otel app:tail:appsignal
rake app=go/go-gin-mysql app:tail:appsignal
rake app=go/go-gin-mysql-collector app:tail:appsignal
rake app=go/gorilla-mux-mysql-redis-mongo app:tail:appsignal
rake app=go/gorilla-mux-mysql-redis-mongo-collector app:tail:appsignal
rake app=java/spring-agent-collector app:tail:appsignal
rake app=java/spring-native-collector app:tail:appsignal
rake app=javascript/Dockerfile app:tail:appsignal
rake app=javascript/ember app:tail:appsignal
rake app=javascript/react app:tail:appsignal
rake app=javascript/react-vite-collector app:tail:appsignal
rake app=javascript/typescript-angular app:tail:appsignal
rake app=javascript/vanilla app:tail:appsignal
rake app=javascript/vue-3 app:tail:appsignal
rake app=javascript/webpack app:tail:appsignal
rake app=nodejs/express-apollo app:tail:appsignal
rake app=nodejs/express-bullmq app:tail:appsignal
rake app=nodejs/express-elasticsearch app:tail:appsignal
rake app=nodejs/express-mongoose app:tail:appsignal
rake app=nodejs/express-postgres app:tail:appsignal
rake app=nodejs/express-postgres-collector app:tail:appsignal
rake app=nodejs/express-rabbitmq app:tail:appsignal
rake app=nodejs/express-redis app:tail:appsignal
rake app=nodejs/express-redis-alpine app:tail:appsignal
rake app=nodejs/express-yoga app:tail:appsignal
rake app=nodejs/fastify app:tail:appsignal
rake app=nodejs/koa-microservices app:tail:appsignal
rake app=nodejs/koa-mongo app:tail:appsignal
rake app=nodejs/koa-mysql app:tail:appsignal
rake app=nodejs/nestjs app:tail:appsignal
rake app=nodejs/nestjs-10 app:tail:appsignal
rake app=nodejs/nestjs-prisma app:tail:appsignal
rake app=nodejs/nextjs-13-app app:tail:appsignal
rake app=nodejs/nextjs-14-app app:tail:appsignal
rake app=nodejs/nextjs-14-pages app:tail:appsignal
rake app=nodejs/nextjs-15-app-collector app:tail:appsignal
rake app=nodejs/remix app:tail:appsignal
rake app=nodejs/restify app:tail:appsignal
rake app=php/laravel-collector app:tail:appsignal
rake app=php/symfony-collector app:tail:appsignal
rake app=php/vanilla-collector app:tail:appsignal
rake app=python/django4-asgi app:tail:appsignal
rake app=python/django4-celery app:tail:appsignal
rake app=python/django4-wsgi app:tail:appsignal
rake app=python/django5-celery app:tail:appsignal
rake app=python/django5-celery-collector app:tail:appsignal
rake app=python/django5-celery-integration-collector app:tail:appsignal
rake app=python/fastapi app:tail:appsignal
rake app=python/fastapi-databases app:tail:appsignal
rake app=python/flask app:tail:appsignal
rake app=python/flask-pika app:tail:appsignal
rake app=python/flask-sqlalchemy app:tail:appsignal
rake app=python/starlette app:tail:appsignal
rake app=ruby/grape app:tail:appsignal
rake app=ruby/hanami2-postgres app:tail:appsignal
rake app=ruby/jruby-rails6 app:tail:appsignal
rake app=ruby/jruby-single-task app:tail:appsignal
rake app=ruby/linux-arm app:tail:appsignal
rake app=ruby/padrino app:tail:appsignal
rake app=ruby/rack app:tail:appsignal
rake app=ruby/rails6-mongo app:tail:appsignal
rake app=ruby/rails6-mysql app:tail:appsignal
rake app=ruby/rails6-shakapacker app:tail:appsignal
rake app=ruby/rails6-shoryuken app:tail:appsignal
rake app=ruby/rails7-delayed-job app:tail:appsignal
rake app=ruby/rails7-goodjob app:tail:appsignal
rake app=ruby/rails7-postgres app:tail:appsignal
rake app=ruby/rails7-sequel app:tail:appsignal
rake app=ruby/rails7-sidekiq app:tail:appsignal
rake app=ruby/rails7-solid-cache app:tail:appsignal
rake app=ruby/rails7-solid-queue app:tail:appsignal
rake app=ruby/rails8-sidekiq app:tail:appsignal
rake app=ruby/rails8-sidekiq-collector app:tail:appsignal
rake app=ruby/shoryuken app:tail:appsignal
rake app=ruby/sinatra-alpine app:tail:appsignal
rake app=ruby/sinatra-gvltools app:tail:appsignal
rake app=ruby/sinatra-puma app:tail:appsignal
rake app=ruby/sinatra-redis app:tail:appsignal
rake app=ruby/single-task app:tail:appsignal
rake app=ruby/webmachine1 app:tail:appsignal
rake app=ruby/webmachine2 app:tail:appsignal
rake app=standalone/nginx app:tail:appsignal
rake app=vector/mongodb app:tail:appsignal
```

Open the browser pointing to the app:

```
rake app:open
```

Reset the integrations to their current `main`:

```
rake integrations:reset
```

## Generate a new test setup

To generate a new test setup run:

```
rake app=lang/app app:new
```

Then customize the generated files and place your code in `app` within
the generated skeleton app. Make sure to map the port to localhost to
`4001`. If you want to run tasks such as generators do that from within
the Docker setup by using the `app:bash` task.

## Processmon

The test setups use a tool called `processmon` to reload their primary running
process. The version is specified in `support/processmon/Dockerfile`.

To bundle the latest version:

```
rake global:install_processmon
```
