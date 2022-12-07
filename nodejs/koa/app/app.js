const { appsignal } = require("./appsignal");
appsignal.instrument(require("@appsignal/koa"));

const Koa = require('koa');
const Router = require('@koa/router');

const app = new Koa();
const router = new Router();

console.log("Starting KOA app");

// Track errors in AppSignal

app.on("error", (error) => {
  appsignal
    .tracer()
    .setError(error)
});

// logger

app.use(async (ctx, next) => {
  await next();
  const rt = ctx.response.get('X-Response-Time');
  console.log(`${ctx.method} ${ctx.url} - ${rt}`);
});

// x-response-time

app.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  ctx.set('X-Response-Time', `${ms}ms`);
});

// routes

router.get('/', ctx => {
  ctx.body = 'Hello World';
})

router.get('/slow', async ctx => {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  ctx.body = 'Well, that took forever!'
})

router.get('/error', ctx => {
  ctx.throw(500, "This is a Koa error!")
})

app
  .use(router.routes())
  .use(router.allowedMethods());

app.listen(process.env.PORT);
