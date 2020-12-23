# Test setups

Run test setups using Docker, requirements to run this:

* A recent Docker version that includes Compose.
* Any 2.0+ version of Ruby

Next, checkout the integrations locally:

```
rake integrations:clone
```

Copy the example key env file and add a valid push api key:

```
cp appsignal_key.env.example appsignal_key.env
```

To start a test setup:

```
rake app=lang/app app:up
```

This will boot a test environment with AppSignal enabled listening on
[localhost](http://localhost:3000). The agent log and lock files are
accessible in the `working_directory`.

To run commands:

```
rake app=lang/app app:bash
rake app=lang/app app:console
```

Tail the appsignal log:

```
rake app=lang/app app:tail:appsignal
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
