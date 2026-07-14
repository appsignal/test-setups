# Rails 6 + Shakapacker example

## Preparation

This setup has a browser (`@appsignal/javascript`) integration, so it needs a
separate **front-end API key** in addition to the repo-root push key. The
front-end key is found under the app's settings in AppSignal, and is not the
same as the backend push API key.

Copy the example file and fill in the key:

```
cp appsignal_key.env.example appsignal_key.env
```

```env
# appsignal_key.env
APPSIGNAL_FRONTEND_API_KEY=00000000-0000-0000-0000-000000000000
```

## Usage

First, change the revision in `app/config/appsignal.yml` if you want to test
new sourcemaps or have made a change to any of the JavaScript assets.

Create assets and upload sourcemaps:

```
cd app
bin/rails sourcemaps
```

Start rails:

```
cd app
bin/rails s -e production
```
