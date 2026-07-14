# JavaScript + webpack test app

## Usage

This app has a browser integration, so it needs a front-end API key (separate
from the backend push key). Copy the example key file and fill it in:

```
cp appsignal_key.env.example appsignal_key.env
```

Then set `APPSIGNAL_FRONTEND_API_KEY` in `appsignal_key.env`.

Run `rake app=javascript/webpack app:up` to prepare the app environment and build the integration.
Run `rake app=javascript/webpack app:console` to run the webserver. Restart the command after updating the `REVISION` file to submit the sourcemaps for the new revision.

Visit `https://localhost:4001` on the host machine to load the app in the
browser and send a demo and custom error.
