# Test setups

Experiment to run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

Copy the example key env file and add a key:

```
cp appsignal_key.env.example appsignal_key.env
```

To start a test setup:

```
rake app=elixir/demo-alpine app:up
rake app=ruby/rails-postgres app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:3000). The agent log and lock files are
accessible in the `working_directory`.

To run commands:

```
rake app=path-to-app app:bash
rake app=path-to-app app:console
```

Tail the appsignal log:

```
rake app=path-to-app app:tail:appsignal
```

Open the browser pointing to the app:

```
rake app:open
```

## Generate a new test setup

To generate a new test setup run:

```
rake app=lang/app app:new
```

Then customize the generated files and place your code in `app` within
the generated skeleton app. Make sure to map the port to localhost to
`3000`.
