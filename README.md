# Test setups

<!-- Generated from support/templates/README.md.erb -->

Run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

Pick the environment to send data to. The `local` and `staging` environments
work out of the box:

```
rake env:local
rake env:staging
```

Switching writes an `appsignal_key.<name>.env` file (seeded from a committed
`appsignal_key.<name>.env.example` default when there is one) and copies it into
`appsignal_key.env`, the file every test setup reads, tagging it with an
`# ENV: <name>` marker. The active environment's contents are printed on boot,
so you can always see which one is in use.

Pass a push api key (you can get one on [AppSignal](https://appsignal.com)) to
set it for that environment while switching; it's remembered on later switches:

```
rake env:prod key=<key>
```

`env:local`, `env:staging` and `env:prod` are shortcuts for the general form,
which works for any environment name:

```
rake env=<name> key=<key> env:switch
```

To start a test setup:

```
rake app=elixir/alpine-release app:up
rake app=elixir/phoenix app:up
rake app=elixir/phoenix-ash app:up
rake app=elixir/phoenix-oban app:up
rake app=elixir/phoenix-opentelemetry app:up
rake app=elixir/plug app:up
rake app=elixir/plug-ecto app:up
rake app=elixir/plug-oban app:up
rake app=elixir/single-task app:up
rake app=go/beego app:up
rake app=go/beego-mod-otel app:up
rake app=go/go-gin-mysql app:up
rake app=go/go-gin-mysql-opentelemetry app:up
rake app=go/gorilla-mux-mysql-redis-mongo app:up
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:up
rake app=java/spring-agent-opentelemetry app:up
rake app=java/spring-native-opentelemetry app:up
rake app=javascript/Dockerfile app:up
rake app=javascript/ember app:up
rake app=javascript/react app:up
rake app=javascript/react-vite-opentelemetry app:up
rake app=javascript/typescript-angular app:up
rake app=javascript/vanilla app:up
rake app=javascript/vue-3 app:up
rake app=javascript/webpack app:up
rake app=nodejs/express-apollo app:up
rake app=nodejs/express-bullmq app:up
rake app=nodejs/express-elasticsearch app:up
rake app=nodejs/express-mongoose app:up
rake app=nodejs/express-postgres app:up
rake app=nodejs/express-postgres-opentelemetry app:up
rake app=nodejs/express-rabbitmq app:up
rake app=nodejs/express-redis app:up
rake app=nodejs/express-redis-alpine app:up
rake app=nodejs/express-yoga app:up
rake app=nodejs/fastify app:up
rake app=nodejs/koa-2-microservices app:up
rake app=nodejs/koa-2-mongo app:up
rake app=nodejs/koa-2-mysql app:up
rake app=nodejs/koa-3-mysql app:up
rake app=nodejs/nestjs app:up
rake app=nodejs/nestjs-10 app:up
rake app=nodejs/nestjs-prisma app:up
rake app=nodejs/nextjs-13-app app:up
rake app=nodejs/nextjs-14-app app:up
rake app=nodejs/nextjs-14-pages app:up
rake app=nodejs/nextjs-15-app-opentelemetry app:up
rake app=nodejs/remix app:up
rake app=nodejs/restify app:up
rake app=php/laravel app:up
rake app=php/laravel-opentelemetry app:up
rake app=php/symfony app:up
rake app=php/symfony-opentelemetry app:up
rake app=php/vanilla app:up
rake app=php/vanilla-opentelemetry app:up
rake app=python/django4-asgi app:up
rake app=python/django4-celery app:up
rake app=python/django4-wsgi app:up
rake app=python/django5-celery app:up
rake app=python/django5-celery-opentelemetry app:up
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
rake app=ruby/rails8-delayed-job app:up
rake app=ruby/rails8-que app:up
rake app=ruby/rails8-resque app:up
rake app=ruby/rails8-sidekiq app:up
rake app=ruby/rails8-sidekiq-opentelemetry app:up
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

To start a test setup with the bot generating activity (loads the index
page and follows a random link every 5 seconds):

```
rake app=elixir/alpine-release app:bot
rake app=elixir/phoenix app:bot
rake app=elixir/phoenix-ash app:bot
rake app=elixir/phoenix-oban app:bot
rake app=elixir/phoenix-opentelemetry app:bot
rake app=elixir/plug app:bot
rake app=elixir/plug-ecto app:bot
rake app=elixir/plug-oban app:bot
rake app=go/beego app:bot
rake app=go/beego-mod-otel app:bot
rake app=go/go-gin-mysql app:bot
rake app=go/go-gin-mysql-opentelemetry app:bot
rake app=go/gorilla-mux-mysql-redis-mongo app:bot
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:bot
rake app=java/spring-agent-opentelemetry app:bot
rake app=java/spring-native-opentelemetry app:bot
rake app=nodejs/express-apollo app:bot
rake app=nodejs/express-bullmq app:bot
rake app=nodejs/express-elasticsearch app:bot
rake app=nodejs/express-mongoose app:bot
rake app=nodejs/express-postgres app:bot
rake app=nodejs/express-postgres-opentelemetry app:bot
rake app=nodejs/express-rabbitmq app:bot
rake app=nodejs/express-redis app:bot
rake app=nodejs/express-redis-alpine app:bot
rake app=nodejs/express-yoga app:bot
rake app=nodejs/fastify app:bot
rake app=nodejs/koa-2-microservices app:bot
rake app=nodejs/koa-2-mongo app:bot
rake app=nodejs/koa-2-mysql app:bot
rake app=nodejs/nestjs app:bot
rake app=nodejs/nestjs-10 app:bot
rake app=nodejs/nestjs-prisma app:bot
rake app=nodejs/nextjs-13-app app:bot
rake app=nodejs/nextjs-14-app app:bot
rake app=nodejs/nextjs-14-pages app:bot
rake app=nodejs/nextjs-15-app-opentelemetry app:bot
rake app=nodejs/remix app:bot
rake app=nodejs/restify app:bot
rake app=php/laravel-opentelemetry app:bot
rake app=php/symfony-opentelemetry app:bot
rake app=php/vanilla-opentelemetry app:bot
rake app=python/django4-asgi app:bot
rake app=python/django4-celery app:bot
rake app=python/django4-wsgi app:bot
rake app=python/django5-celery app:bot
rake app=python/django5-celery-opentelemetry app:bot
rake app=python/fastapi app:bot
rake app=python/fastapi-databases app:bot
rake app=python/flask app:bot
rake app=python/flask-pika app:bot
rake app=python/flask-sqlalchemy app:bot
rake app=python/starlette app:bot
rake app=ruby/grape app:bot
rake app=ruby/hanami2-postgres app:bot
rake app=ruby/jruby-rails6 app:bot
rake app=ruby/linux-arm app:bot
rake app=ruby/padrino app:bot
rake app=ruby/rack app:bot
rake app=ruby/rails6-mongo app:bot
rake app=ruby/rails6-mysql app:bot
rake app=ruby/rails6-shakapacker app:bot
rake app=ruby/rails6-shoryuken app:bot
rake app=ruby/rails7-delayed-job app:bot
rake app=ruby/rails7-goodjob app:bot
rake app=ruby/rails7-postgres app:bot
rake app=ruby/rails7-sequel app:bot
rake app=ruby/rails7-sidekiq app:bot
rake app=ruby/rails7-solid-cache app:bot
rake app=ruby/rails7-solid-queue app:bot
rake app=ruby/rails8-que app:bot
rake app=ruby/rails8-resque app:bot
rake app=ruby/rails8-sidekiq app:bot
rake app=ruby/rails8-sidekiq-opentelemetry app:bot
rake app=ruby/sinatra-alpine app:bot
rake app=ruby/sinatra-gvltools app:bot
rake app=ruby/sinatra-puma app:bot
rake app=ruby/sinatra-redis app:bot
rake app=ruby/webmachine1 app:bot
rake app=ruby/webmachine2 app:bot
```

Each test setup can be run in one or more "modes", selected with the `mode=`
parameter. A mode is defined by a `docker-compose.<mode>.yml` file in the setup
directory. When no `mode=` is given, the setup runs in its default mode (its
plain `docker-compose.yml`), or in `agent` mode when it has no default.

Most setups run their integration in "agent mode". Some also support "collector
mode", in which the integration sends data to AppSignal through a local
AppSignal collector over OpenTelemetry. Pass `mode=collector` to any command.
The setups that support collector mode:

```
rake app=python/django4-asgi mode=collector app:up
rake app=python/django4-celery mode=collector app:up
rake app=python/django4-wsgi mode=collector app:up
rake app=python/django5-celery mode=collector app:up
rake app=python/fastapi mode=collector app:up
rake app=python/fastapi-databases mode=collector app:up
rake app=python/flask mode=collector app:up
rake app=python/flask-pika mode=collector app:up
rake app=python/flask-sqlalchemy mode=collector app:up
rake app=python/starlette mode=collector app:up
rake app=ruby/grape mode=collector app:up
rake app=ruby/hanami2-postgres mode=collector app:up
rake app=ruby/rack mode=collector app:up
rake app=ruby/rails6-mysql mode=collector app:up
rake app=ruby/rails6-shakapacker mode=collector app:up
rake app=ruby/rails6-shoryuken mode=collector app:up
rake app=ruby/rails7-delayed-job mode=collector app:up
rake app=ruby/rails7-goodjob mode=collector app:up
rake app=ruby/rails7-postgres mode=collector app:up
rake app=ruby/rails7-sequel mode=collector app:up
rake app=ruby/rails7-sidekiq mode=collector app:up
rake app=ruby/rails7-solid-cache mode=collector app:up
rake app=ruby/rails7-solid-queue mode=collector app:up
rake app=ruby/rails8-delayed-job mode=collector app:up
rake app=ruby/rails8-que mode=collector app:up
rake app=ruby/rails8-resque mode=collector app:up
rake app=ruby/rails8-sidekiq mode=collector app:up
rake app=ruby/sinatra-alpine mode=collector app:up
rake app=ruby/sinatra-gvltools mode=collector app:up
rake app=ruby/webmachine1 mode=collector app:up
rake app=ruby/webmachine2 mode=collector app:up
```

To restart the app container after making changes to an integration:

```
rake app=elixir/alpine-release app:restart
rake app=elixir/phoenix app:restart
rake app=elixir/phoenix-ash app:restart
rake app=elixir/phoenix-oban app:restart
rake app=elixir/phoenix-opentelemetry app:restart
rake app=elixir/plug app:restart
rake app=elixir/plug-ecto app:restart
rake app=elixir/plug-oban app:restart
rake app=elixir/single-task app:restart
rake app=go/beego app:restart
rake app=go/beego-mod-otel app:restart
rake app=go/go-gin-mysql app:restart
rake app=go/go-gin-mysql-opentelemetry app:restart
rake app=go/gorilla-mux-mysql-redis-mongo app:restart
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:restart
rake app=java/spring-agent-opentelemetry app:restart
rake app=java/spring-native-opentelemetry app:restart
rake app=javascript/Dockerfile app:restart
rake app=javascript/ember app:restart
rake app=javascript/react app:restart
rake app=javascript/react-vite-opentelemetry app:restart
rake app=javascript/typescript-angular app:restart
rake app=javascript/vanilla app:restart
rake app=javascript/vue-3 app:restart
rake app=javascript/webpack app:restart
rake app=nodejs/express-apollo app:restart
rake app=nodejs/express-bullmq app:restart
rake app=nodejs/express-elasticsearch app:restart
rake app=nodejs/express-mongoose app:restart
rake app=nodejs/express-postgres app:restart
rake app=nodejs/express-postgres-opentelemetry app:restart
rake app=nodejs/express-rabbitmq app:restart
rake app=nodejs/express-redis app:restart
rake app=nodejs/express-redis-alpine app:restart
rake app=nodejs/express-yoga app:restart
rake app=nodejs/fastify app:restart
rake app=nodejs/koa-2-microservices app:restart
rake app=nodejs/koa-2-mongo app:restart
rake app=nodejs/koa-2-mysql app:restart
rake app=nodejs/koa-3-mysql app:restart
rake app=nodejs/nestjs app:restart
rake app=nodejs/nestjs-10 app:restart
rake app=nodejs/nestjs-prisma app:restart
rake app=nodejs/nextjs-13-app app:restart
rake app=nodejs/nextjs-14-app app:restart
rake app=nodejs/nextjs-14-pages app:restart
rake app=nodejs/nextjs-15-app-opentelemetry app:restart
rake app=nodejs/remix app:restart
rake app=nodejs/restify app:restart
rake app=php/laravel app:restart
rake app=php/laravel-opentelemetry app:restart
rake app=php/symfony app:restart
rake app=php/symfony-opentelemetry app:restart
rake app=php/vanilla app:restart
rake app=php/vanilla-opentelemetry app:restart
rake app=python/django4-asgi app:restart
rake app=python/django4-celery app:restart
rake app=python/django4-wsgi app:restart
rake app=python/django5-celery app:restart
rake app=python/django5-celery-opentelemetry app:restart
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
rake app=ruby/rails8-delayed-job app:restart
rake app=ruby/rails8-que app:restart
rake app=ruby/rails8-resque app:restart
rake app=ruby/rails8-sidekiq app:restart
rake app=ruby/rails8-sidekiq-opentelemetry app:restart
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
rake app=elixir/phoenix-ash app:bash
rake app=elixir/phoenix-oban app:bash
rake app=elixir/phoenix-opentelemetry app:bash
rake app=elixir/plug app:bash
rake app=elixir/plug-ecto app:bash
rake app=elixir/plug-oban app:bash
rake app=elixir/single-task app:bash
rake app=go/beego app:bash
rake app=go/beego-mod-otel app:bash
rake app=go/go-gin-mysql app:bash
rake app=go/go-gin-mysql-opentelemetry app:bash
rake app=go/gorilla-mux-mysql-redis-mongo app:bash
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:bash
rake app=java/spring-agent-opentelemetry app:bash
rake app=java/spring-native-opentelemetry app:bash
rake app=javascript/Dockerfile app:bash
rake app=javascript/ember app:bash
rake app=javascript/react app:bash
rake app=javascript/react-vite-opentelemetry app:bash
rake app=javascript/typescript-angular app:bash
rake app=javascript/vanilla app:bash
rake app=javascript/vue-3 app:bash
rake app=javascript/webpack app:bash
rake app=nodejs/express-apollo app:bash
rake app=nodejs/express-bullmq app:bash
rake app=nodejs/express-elasticsearch app:bash
rake app=nodejs/express-mongoose app:bash
rake app=nodejs/express-postgres app:bash
rake app=nodejs/express-postgres-opentelemetry app:bash
rake app=nodejs/express-rabbitmq app:bash
rake app=nodejs/express-redis app:bash
rake app=nodejs/express-redis-alpine app:bash
rake app=nodejs/express-yoga app:bash
rake app=nodejs/fastify app:bash
rake app=nodejs/koa-2-microservices app:bash
rake app=nodejs/koa-2-mongo app:bash
rake app=nodejs/koa-2-mysql app:bash
rake app=nodejs/koa-3-mysql app:bash
rake app=nodejs/nestjs app:bash
rake app=nodejs/nestjs-10 app:bash
rake app=nodejs/nestjs-prisma app:bash
rake app=nodejs/nextjs-13-app app:bash
rake app=nodejs/nextjs-14-app app:bash
rake app=nodejs/nextjs-14-pages app:bash
rake app=nodejs/nextjs-15-app-opentelemetry app:bash
rake app=nodejs/remix app:bash
rake app=nodejs/restify app:bash
rake app=php/laravel app:bash
rake app=php/laravel-opentelemetry app:bash
rake app=php/symfony app:bash
rake app=php/symfony-opentelemetry app:bash
rake app=php/vanilla app:bash
rake app=php/vanilla-opentelemetry app:bash
rake app=python/django4-asgi app:bash
rake app=python/django4-celery app:bash
rake app=python/django4-wsgi app:bash
rake app=python/django5-celery app:bash
rake app=python/django5-celery-opentelemetry app:bash
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
rake app=ruby/rails8-delayed-job app:bash
rake app=ruby/rails8-que app:bash
rake app=ruby/rails8-resque app:bash
rake app=ruby/rails8-sidekiq app:bash
rake app=ruby/rails8-sidekiq-opentelemetry app:bash
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
rake app=elixir/phoenix-ash app:console
rake app=elixir/phoenix-oban app:console
rake app=elixir/phoenix-opentelemetry app:console
rake app=elixir/plug app:console
rake app=elixir/plug-ecto app:console
rake app=elixir/plug-oban app:console
rake app=elixir/single-task app:console
rake app=go/beego app:console
rake app=go/beego-mod-otel app:console
rake app=go/go-gin-mysql app:console
rake app=go/go-gin-mysql-opentelemetry app:console
rake app=go/gorilla-mux-mysql-redis-mongo app:console
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:console
rake app=java/spring-agent-opentelemetry app:console
rake app=java/spring-native-opentelemetry app:console
rake app=javascript/Dockerfile app:console
rake app=javascript/ember app:console
rake app=javascript/react app:console
rake app=javascript/react-vite-opentelemetry app:console
rake app=javascript/typescript-angular app:console
rake app=javascript/vanilla app:console
rake app=javascript/vue-3 app:console
rake app=javascript/webpack app:console
rake app=nodejs/express-apollo app:console
rake app=nodejs/express-bullmq app:console
rake app=nodejs/express-elasticsearch app:console
rake app=nodejs/express-mongoose app:console
rake app=nodejs/express-postgres app:console
rake app=nodejs/express-postgres-opentelemetry app:console
rake app=nodejs/express-rabbitmq app:console
rake app=nodejs/express-redis app:console
rake app=nodejs/express-redis-alpine app:console
rake app=nodejs/express-yoga app:console
rake app=nodejs/fastify app:console
rake app=nodejs/koa-2-microservices app:console
rake app=nodejs/koa-2-mongo app:console
rake app=nodejs/koa-2-mysql app:console
rake app=nodejs/koa-3-mysql app:console
rake app=nodejs/nestjs app:console
rake app=nodejs/nestjs-10 app:console
rake app=nodejs/nestjs-prisma app:console
rake app=nodejs/nextjs-13-app app:console
rake app=nodejs/nextjs-14-app app:console
rake app=nodejs/nextjs-14-pages app:console
rake app=nodejs/nextjs-15-app-opentelemetry app:console
rake app=nodejs/remix app:console
rake app=nodejs/restify app:console
rake app=php/laravel app:console
rake app=php/laravel-opentelemetry app:console
rake app=php/symfony app:console
rake app=php/symfony-opentelemetry app:console
rake app=php/vanilla app:console
rake app=php/vanilla-opentelemetry app:console
rake app=python/django4-asgi app:console
rake app=python/django4-celery app:console
rake app=python/django4-wsgi app:console
rake app=python/django5-celery app:console
rake app=python/django5-celery-opentelemetry app:console
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
rake app=ruby/rails8-delayed-job app:console
rake app=ruby/rails8-que app:console
rake app=ruby/rails8-resque app:console
rake app=ruby/rails8-sidekiq app:console
rake app=ruby/rails8-sidekiq-opentelemetry app:console
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
rake app=elixir/phoenix-ash app:diagnose
rake app=elixir/phoenix-oban app:diagnose
rake app=elixir/phoenix-opentelemetry app:diagnose
rake app=elixir/plug app:diagnose
rake app=elixir/plug-ecto app:diagnose
rake app=elixir/plug-oban app:diagnose
rake app=elixir/single-task app:diagnose
rake app=go/beego app:diagnose
rake app=go/beego-mod-otel app:diagnose
rake app=go/go-gin-mysql app:diagnose
rake app=go/go-gin-mysql-opentelemetry app:diagnose
rake app=go/gorilla-mux-mysql-redis-mongo app:diagnose
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:diagnose
rake app=java/spring-agent-opentelemetry app:diagnose
rake app=java/spring-native-opentelemetry app:diagnose
rake app=javascript/Dockerfile app:diagnose
rake app=javascript/ember app:diagnose
rake app=javascript/react app:diagnose
rake app=javascript/react-vite-opentelemetry app:diagnose
rake app=javascript/typescript-angular app:diagnose
rake app=javascript/vanilla app:diagnose
rake app=javascript/vue-3 app:diagnose
rake app=javascript/webpack app:diagnose
rake app=nodejs/express-apollo app:diagnose
rake app=nodejs/express-bullmq app:diagnose
rake app=nodejs/express-elasticsearch app:diagnose
rake app=nodejs/express-mongoose app:diagnose
rake app=nodejs/express-postgres app:diagnose
rake app=nodejs/express-postgres-opentelemetry app:diagnose
rake app=nodejs/express-rabbitmq app:diagnose
rake app=nodejs/express-redis app:diagnose
rake app=nodejs/express-redis-alpine app:diagnose
rake app=nodejs/express-yoga app:diagnose
rake app=nodejs/fastify app:diagnose
rake app=nodejs/koa-2-microservices app:diagnose
rake app=nodejs/koa-2-mongo app:diagnose
rake app=nodejs/koa-2-mysql app:diagnose
rake app=nodejs/koa-3-mysql app:diagnose
rake app=nodejs/nestjs app:diagnose
rake app=nodejs/nestjs-10 app:diagnose
rake app=nodejs/nestjs-prisma app:diagnose
rake app=nodejs/nextjs-13-app app:diagnose
rake app=nodejs/nextjs-14-app app:diagnose
rake app=nodejs/nextjs-14-pages app:diagnose
rake app=nodejs/nextjs-15-app-opentelemetry app:diagnose
rake app=nodejs/remix app:diagnose
rake app=nodejs/restify app:diagnose
rake app=php/laravel app:diagnose
rake app=php/laravel-opentelemetry app:diagnose
rake app=php/symfony app:diagnose
rake app=php/symfony-opentelemetry app:diagnose
rake app=php/vanilla app:diagnose
rake app=php/vanilla-opentelemetry app:diagnose
rake app=python/django4-asgi app:diagnose
rake app=python/django4-celery app:diagnose
rake app=python/django4-wsgi app:diagnose
rake app=python/django5-celery app:diagnose
rake app=python/django5-celery-opentelemetry app:diagnose
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
rake app=ruby/rails8-delayed-job app:diagnose
rake app=ruby/rails8-que app:diagnose
rake app=ruby/rails8-resque app:diagnose
rake app=ruby/rails8-sidekiq app:diagnose
rake app=ruby/rails8-sidekiq-opentelemetry app:diagnose
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
rake app=elixir/phoenix-ash app:tail:appsignal
rake app=elixir/phoenix-oban app:tail:appsignal
rake app=elixir/phoenix-opentelemetry app:tail:appsignal
rake app=elixir/plug app:tail:appsignal
rake app=elixir/plug-ecto app:tail:appsignal
rake app=elixir/plug-oban app:tail:appsignal
rake app=elixir/single-task app:tail:appsignal
rake app=go/beego app:tail:appsignal
rake app=go/beego-mod-otel app:tail:appsignal
rake app=go/go-gin-mysql app:tail:appsignal
rake app=go/go-gin-mysql-opentelemetry app:tail:appsignal
rake app=go/gorilla-mux-mysql-redis-mongo app:tail:appsignal
rake app=go/gorilla-mux-mysql-redis-mongo-opentelemetry app:tail:appsignal
rake app=java/spring-agent-opentelemetry app:tail:appsignal
rake app=java/spring-native-opentelemetry app:tail:appsignal
rake app=javascript/Dockerfile app:tail:appsignal
rake app=javascript/ember app:tail:appsignal
rake app=javascript/react app:tail:appsignal
rake app=javascript/react-vite-opentelemetry app:tail:appsignal
rake app=javascript/typescript-angular app:tail:appsignal
rake app=javascript/vanilla app:tail:appsignal
rake app=javascript/vue-3 app:tail:appsignal
rake app=javascript/webpack app:tail:appsignal
rake app=nodejs/express-apollo app:tail:appsignal
rake app=nodejs/express-bullmq app:tail:appsignal
rake app=nodejs/express-elasticsearch app:tail:appsignal
rake app=nodejs/express-mongoose app:tail:appsignal
rake app=nodejs/express-postgres app:tail:appsignal
rake app=nodejs/express-postgres-opentelemetry app:tail:appsignal
rake app=nodejs/express-rabbitmq app:tail:appsignal
rake app=nodejs/express-redis app:tail:appsignal
rake app=nodejs/express-redis-alpine app:tail:appsignal
rake app=nodejs/express-yoga app:tail:appsignal
rake app=nodejs/fastify app:tail:appsignal
rake app=nodejs/koa-2-microservices app:tail:appsignal
rake app=nodejs/koa-2-mongo app:tail:appsignal
rake app=nodejs/koa-2-mysql app:tail:appsignal
rake app=nodejs/koa-3-mysql app:tail:appsignal
rake app=nodejs/nestjs app:tail:appsignal
rake app=nodejs/nestjs-10 app:tail:appsignal
rake app=nodejs/nestjs-prisma app:tail:appsignal
rake app=nodejs/nextjs-13-app app:tail:appsignal
rake app=nodejs/nextjs-14-app app:tail:appsignal
rake app=nodejs/nextjs-14-pages app:tail:appsignal
rake app=nodejs/nextjs-15-app-opentelemetry app:tail:appsignal
rake app=nodejs/remix app:tail:appsignal
rake app=nodejs/restify app:tail:appsignal
rake app=php/laravel app:tail:appsignal
rake app=php/laravel-opentelemetry app:tail:appsignal
rake app=php/symfony app:tail:appsignal
rake app=php/symfony-opentelemetry app:tail:appsignal
rake app=php/vanilla app:tail:appsignal
rake app=php/vanilla-opentelemetry app:tail:appsignal
rake app=python/django4-asgi app:tail:appsignal
rake app=python/django4-celery app:tail:appsignal
rake app=python/django4-wsgi app:tail:appsignal
rake app=python/django5-celery app:tail:appsignal
rake app=python/django5-celery-opentelemetry app:tail:appsignal
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
rake app=ruby/rails8-delayed-job app:tail:appsignal
rake app=ruby/rails8-que app:tail:appsignal
rake app=ruby/rails8-resque app:tail:appsignal
rake app=ruby/rails8-sidekiq app:tail:appsignal
rake app=ruby/rails8-sidekiq-opentelemetry app:tail:appsignal
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
