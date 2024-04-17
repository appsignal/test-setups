# Next.js example app

## Error route

To trigger an error route, visit [http://localhost:4001/error?error=yes](http://localhost:4001/error?error=yes). Needs a query param, because otherwise the `npm run build` step's prerender step always throws the error and it can't build.

## Production mode

This app starts by default in development mode.

If you want to run Next.js in production mode, use the `build_arg=NODE_ENV=production` argument on boot.

Example:

```
rake app=nodejs/v3/nextjs build_arg=NODE_ENV=production app:up
```
