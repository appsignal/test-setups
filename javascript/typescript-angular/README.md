# Typescript Angular test app

Test app using Typescript. Used to test errors that arise from compilation.

## Preparation

This app has a browser integration, so it needs a front-end API key (separate
from the backend push key). Copy the example key file and fill it in:

```
cp appsignal_key.env.example appsignal_key.env
```

Then set `APPSIGNAL_FRONTEND_API_KEY` in `appsignal_key.env`.
