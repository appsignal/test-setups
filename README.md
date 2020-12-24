# Test setups

<!-- Generated from support/templates/README.md.erb -->

Run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

Generate an environment file using a valid push api key,
this file is ignored by git:

```
rake global:set_push_api_key key=<key>
```

To start a test setup:

```
rake elixir/alpine-release app:up
rake elixir/phoenix-example app:up
rake ruby/rails-postgres app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:3000). The agent log and lock files are
accessible in the `working_directory`.

To run bash:

```
rake elixir/alpine-release app:bash
rake elixir/phoenix-example app:bash
rake ruby/rails-postgres app:bash
```

To run the console:

```
rake elixir/alpine-release app:console
rake elixir/phoenix-example app:console
rake ruby/rails-postgres app:console
```

Tail the appsignal log:

```
rake elixir/alpine-release app:tail:appsignal
rake elixir/phoenix-example app:tail:appsignal
rake ruby/rails-postgres app:tail:appsignal
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
`3000`. If you want to run tasks such as generators do that from within
the Docker setup by using the `app:bash` task.
