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
rake app=elixir/phoenix-example app:up
rake app=elixir/single-task app:up
rake app=ruby/jruby-single-task app:up
rake app=ruby/linux-arm app:up
rake app=ruby/padrino app:up
rake app=ruby/rails6-mongo app:up
rake app=ruby/rails6-postgres app:up
rake app=ruby/rails6-sequel app:up
rake app=ruby/rails6-sidekiq app:up
rake app=ruby/shoryuken app:up
rake app=ruby/sinatra app:up
rake app=ruby/sinatra-puma app:up
rake app=ruby/single-task app:up
rake app=ruby/webmachine app:up
rake app=nodejs/express-apollo app:up
rake app=nodejs/express-postgres app:up
rake app=nodejs/express-redis app:up
rake app=nodejs/koa app:up
rake app=nodejs/next-js app:up
rake app=nodejs/open-telemetry app:up
rake app=javascript/Dockerfile app:up
rake app=javascript/ember app:up
rake app=javascript/react app:up
rake app=javascript/typescript-angular app:up
rake app=javascript/vanilla app:up
rake app=javascript/vue-2 app:up
rake app=javascript/vue-3 app:up
rake app=javascript/webpack app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:4001). The agent log and lock files are
accessible in the `working_directory`.

To restart the app container after making changes to an integration:

```
rake app=elixir/alpine-release app:restart
rake app=elixir/phoenix-example app:restart
rake app=elixir/single-task app:restart
rake app=ruby/jruby-single-task app:restart
rake app=ruby/linux-arm app:restart
rake app=ruby/padrino app:restart
rake app=ruby/rails6-mongo app:restart
rake app=ruby/rails6-postgres app:restart
rake app=ruby/rails6-sequel app:restart
rake app=ruby/rails6-sidekiq app:restart
rake app=ruby/shoryuken app:restart
rake app=ruby/sinatra app:restart
rake app=ruby/sinatra-puma app:restart
rake app=ruby/single-task app:restart
rake app=ruby/webmachine app:restart
rake app=nodejs/express-apollo app:restart
rake app=nodejs/express-postgres app:restart
rake app=nodejs/express-redis app:restart
rake app=nodejs/koa app:restart
rake app=nodejs/next-js app:restart
rake app=nodejs/open-telemetry app:restart
rake app=javascript/Dockerfile app:restart
rake app=javascript/ember app:restart
rake app=javascript/react app:restart
rake app=javascript/typescript-angular app:restart
rake app=javascript/vanilla app:restart
rake app=javascript/vue-2 app:restart
rake app=javascript/vue-3 app:restart
rake app=javascript/webpack app:restart
```

To run bash:

```
rake app=elixir/alpine-release app:bash
rake app=elixir/phoenix-example app:bash
rake app=elixir/single-task app:bash
rake app=ruby/jruby-single-task app:bash
rake app=ruby/linux-arm app:bash
rake app=ruby/padrino app:bash
rake app=ruby/rails6-mongo app:bash
rake app=ruby/rails6-postgres app:bash
rake app=ruby/rails6-sequel app:bash
rake app=ruby/rails6-sidekiq app:bash
rake app=ruby/shoryuken app:bash
rake app=ruby/sinatra app:bash
rake app=ruby/sinatra-puma app:bash
rake app=ruby/single-task app:bash
rake app=ruby/webmachine app:bash
rake app=nodejs/express-apollo app:bash
rake app=nodejs/express-postgres app:bash
rake app=nodejs/express-redis app:bash
rake app=nodejs/koa app:bash
rake app=nodejs/next-js app:bash
rake app=nodejs/open-telemetry app:bash
rake app=javascript/Dockerfile app:bash
rake app=javascript/ember app:bash
rake app=javascript/react app:bash
rake app=javascript/typescript-angular app:bash
rake app=javascript/vanilla app:bash
rake app=javascript/vue-2 app:bash
rake app=javascript/vue-3 app:bash
rake app=javascript/webpack app:bash
```

To run the console (if implemented in the test app):

```
rake app=elixir/alpine-release app:console
rake app=elixir/phoenix-example app:console
rake app=elixir/single-task app:console
rake app=ruby/jruby-single-task app:console
rake app=ruby/linux-arm app:console
rake app=ruby/padrino app:console
rake app=ruby/rails6-mongo app:console
rake app=ruby/rails6-postgres app:console
rake app=ruby/rails6-sequel app:console
rake app=ruby/rails6-sidekiq app:console
rake app=ruby/shoryuken app:console
rake app=ruby/sinatra app:console
rake app=ruby/sinatra-puma app:console
rake app=ruby/single-task app:console
rake app=ruby/webmachine app:console
rake app=nodejs/express-apollo app:console
rake app=nodejs/express-postgres app:console
rake app=nodejs/express-redis app:console
rake app=nodejs/koa app:console
rake app=nodejs/next-js app:console
rake app=nodejs/open-telemetry app:console
rake app=javascript/Dockerfile app:console
rake app=javascript/ember app:console
rake app=javascript/react app:console
rake app=javascript/typescript-angular app:console
rake app=javascript/vanilla app:console
rake app=javascript/vue-2 app:console
rake app=javascript/vue-3 app:console
rake app=javascript/webpack app:console
```

To send in a diagnose (if implemented in the test app);

```
rake app=elixir/alpine-release app:diagnose
rake app=elixir/phoenix-example app:diagnose
rake app=elixir/single-task app:diagnose
rake app=ruby/jruby-single-task app:diagnose
rake app=ruby/linux-arm app:diagnose
rake app=ruby/padrino app:diagnose
rake app=ruby/rails6-mongo app:diagnose
rake app=ruby/rails6-postgres app:diagnose
rake app=ruby/rails6-sequel app:diagnose
rake app=ruby/rails6-sidekiq app:diagnose
rake app=ruby/shoryuken app:diagnose
rake app=ruby/sinatra app:diagnose
rake app=ruby/sinatra-puma app:diagnose
rake app=ruby/single-task app:diagnose
rake app=ruby/webmachine app:diagnose
rake app=nodejs/express-apollo app:diagnose
rake app=nodejs/express-postgres app:diagnose
rake app=nodejs/express-redis app:diagnose
rake app=nodejs/koa app:diagnose
rake app=nodejs/next-js app:diagnose
rake app=nodejs/open-telemetry app:diagnose
rake app=javascript/Dockerfile app:diagnose
rake app=javascript/ember app:diagnose
rake app=javascript/react app:diagnose
rake app=javascript/typescript-angular app:diagnose
rake app=javascript/vanilla app:diagnose
rake app=javascript/vue-2 app:diagnose
rake app=javascript/vue-3 app:diagnose
rake app=javascript/webpack app:diagnose
```

Tail the appsignal log:

```
rake app=elixir/alpine-release app:tail:appsignal
rake app=elixir/phoenix-example app:tail:appsignal
rake app=elixir/single-task app:tail:appsignal
rake app=ruby/jruby-single-task app:tail:appsignal
rake app=ruby/linux-arm app:tail:appsignal
rake app=ruby/padrino app:tail:appsignal
rake app=ruby/rails6-mongo app:tail:appsignal
rake app=ruby/rails6-postgres app:tail:appsignal
rake app=ruby/rails6-sequel app:tail:appsignal
rake app=ruby/rails6-sidekiq app:tail:appsignal
rake app=ruby/shoryuken app:tail:appsignal
rake app=ruby/sinatra app:tail:appsignal
rake app=ruby/sinatra-puma app:tail:appsignal
rake app=ruby/single-task app:tail:appsignal
rake app=ruby/webmachine app:tail:appsignal
rake app=nodejs/express-apollo app:tail:appsignal
rake app=nodejs/express-postgres app:tail:appsignal
rake app=nodejs/express-redis app:tail:appsignal
rake app=nodejs/koa app:tail:appsignal
rake app=nodejs/next-js app:tail:appsignal
rake app=nodejs/open-telemetry app:tail:appsignal
rake app=javascript/Dockerfile app:tail:appsignal
rake app=javascript/ember app:tail:appsignal
rake app=javascript/react app:tail:appsignal
rake app=javascript/typescript-angular app:tail:appsignal
rake app=javascript/vanilla app:tail:appsignal
rake app=javascript/vue-2 app:tail:appsignal
rake app=javascript/vue-3 app:tail:appsignal
rake app=javascript/webpack app:tail:appsignal
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
