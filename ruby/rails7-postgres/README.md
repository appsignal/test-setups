# Rails 7 test app

## Vector

This test setup includes a very small Vector example as well. To use it, you need an app-level Push API key, because our Vector integration works that way. It's mostly set up to test this app's PostgreSQL database metrics.

- [Get the __app-level__ Push API key](https://appsignal.com/redirect-to/app?to=info) of the app you want to report data too, and add it to the `appsignal_key.env` file as follows:
  ```
  APPSIGNAL_VECTOR_APP_PUSH_API_KEY="YOUR-KEY-HERE"
  ```
- Optional, if you want to send data to the AppSignal staging server, change the endpoint in the AppSignal sink in the `vector/vector.toml.template` file:
  ```diff
  diff --git ruby/rails7-postgres/vector/vector.toml.template ruby/rails7-postgres/vector/vector.toml.template
  index 701e51c..9dd349b 100644
  --- ruby/rails7-postgres/vector/vector.toml.template
  +++ ruby/rails7-postgres/vector/vector.toml.template
  @@ -23,5 +23,6 @@ encoding.codec = "text"

   [sinks.appsignal]
   type = "appsignal"
  +endpoint = "https://error-tracker.staging.lol"
   inputs = [ "internal_logs", "modify" ]
   push_api_key = "$APPSIGNAL_VECTOR_APP_PUSH_API_KEY"
  ```
- Optional, if you want to test logs: On the app that corresponds to the Push API key, [create a new log source of the type "Vector"](https://appsignal.com/redirect-to/app?to=logs/sources&overlay=logSourceFormOverlay&name=vector&fmt=PLAINTEXT&type=vector).
- Start the app.

The vector config can be found in `vector.toml`.
