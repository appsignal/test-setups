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
rake app=ruby/shoryuken app:up
rake app=ruby/single-task app:up
rake app=ruby/rails-postgres app:up
rake app=nodejs/express-postgres app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:4001). The agent log and lock files are
accessible in the `working_directory`.

To restart the app container after making changes to an integration:

```
rake app=elixir/alpine-release app:restart
rake app=elixir/phoenix-example app:restart
rake app=ruby/shoryuken app:restart
rake app=ruby/single-task app:restart
rake app=ruby/rails-postgres app:restart
rake app=nodejs/express-postgres app:restart
```

To run bash:

```
rake app=elixir/alpine-release app:bash
rake app=elixir/phoenix-example app:bash
rake app=ruby/shoryuken app:bash
rake app=ruby/single-task app:bash
rake app=ruby/rails-postgres app:bash
rake app=nodejs/express-postgres app:bash
```

To run the console (if implemented in the test app):

```
rake app=elixir/alpine-release app:console
rake app=elixir/phoenix-example app:console
rake app=ruby/shoryuken app:console
rake app=ruby/single-task app:console
rake app=ruby/rails-postgres app:console
rake app=nodejs/express-postgres app:console
```

To send in a diagnose (if implemented in the test app);

```
rake app=elixir/alpine-release app:diagnose
rake app=elixir/phoenix-example app:diagnose
rake app=ruby/shoryuken app:diagnose
rake app=ruby/single-task app:diagnose
rake app=ruby/rails-postgres app:diagnose
rake app=nodejs/express-postgres app:diagnose
```

Tail the appsignal log:

```
rake app=elixir/alpine-release app:tail:appsignal
rake app=elixir/phoenix-example app:tail:appsignal
rake app=ruby/shoryuken app:tail:appsignal
rake app=ruby/single-task app:tail:appsignal
rake app=ruby/rails-postgres app:tail:appsignal
rake app=nodejs/express-postgres app:tail:appsignal
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
