# Next.js Page router app

For front-end error reporting to work, add a `appsignal_key.env` file (example
can be found in `appsignal_key.env.example`), and add the front-end API key for
the specific existing app you want to add the front-end errors to.

## Client-side dynamic route fetching data in the client

Make a request to [/stargazers/vercel/next.js](http://localhost:4001/stargazers/vercel/next.js) to test how a route using client side data fetching reports its data. This is different from using [getServerSideProps](https://nextjs.org/docs/pages/building-your-application/data-fetching/get-server-side-props), because it doesn't hit the Next.js server.

## Production mode

This app starts by default in development mode.

If you want to run Next.js in production mode, use the `build_arg=NODE_ENV=production` argument on boot.

Example:

```
rake app=nodejs/v3/nextjs-noappdir build_arg=NODE_ENV=production app:up
```
