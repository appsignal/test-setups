# Rails 6 + Shakapacker example

## Preparation

Add the front-end API key of the app you want to report the errors to in the
`ruby/rails6-shakapacker/appsignal_key.env` file.

```env
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
