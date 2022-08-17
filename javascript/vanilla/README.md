# Vanilla JavaScript test app

This setup tests the core front-end integration, as well as the framework-independent plugins:

- `plugin-path-decorator`
- `plugin-window-events`
- `plugin-breadcrumbs-console`
- `plugin-breadcrumbs-network`

## Setup

- Create a front-end app on [AppSignal.com](https://appsignal.com/redirect-to/organization?to=sites/new).
- Create an `appsignal_key.env` file in this directory.
    - You can use the `appsignal_key.env.example` file as a template.
- Paste in your API key in the `APPSIGNAL_FRONTEND_KEY` environment variable.
- Start the app.
