# Test setups

Experiment to run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

To start a test setup:

```
rake app=elixir/demo-alpine app:up
rake app=ruby/rails-postgres app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:3000).

To run commands:

```
rake app=path-to-app app:bash
rake app=path-to-app app:console
```

## Expected scripts in container

If the containers supports starting a console it should add a script to
do this in `/commands/console.sh`.
