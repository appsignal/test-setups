const { appsignal } = require("./appsignal");
appsignal.instrument(require("@appsignal/koa"));

const Koa = require('koa');
const app = new Koa();

console.log("Starting KOA app");

// Track errors in AppSignal

app.on("error", (error) => {
  appsignal
    .tracer()
    .currentSpan()
    .addError(error)
    .close()
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

// response

app.use(async ctx => {
  ctx.body = 'Hello World';

  // Uncomment this to throw an error
  //ctx.throw(500,'Error Message');
});

app.listen(3000);
