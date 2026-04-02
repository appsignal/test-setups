const restify = require("restify")

function respond(req: any, res: any, next: any) {
  res.send("hello " + req.params.name)
  next()
}

const server = restify.createServer({ handleUncaughtExceptions: true })
server.use(restify.plugins.queryParser())
server.get("/", function (req: any, res: any, next: any) {
  res.header("Content-Type", "text/html")
  res.sendRaw(`
    <h1>Restify test app</h1>
    <ul>
      <li><a href="/slow">GET /slow</a></li>
      <li><a href="/error">GET /error</a></li>
      <li><a href="/hello/world">GET /hello/:name</a></li>
      <li><a href="/goodbye/world">GET /goodbye/:name</a></li>
    </ul>
  `)
  return next()
})
server.get("/hello/:name", respond)

server.get("/error", function (req: any, res: any, next: any) {
  throw new Error("Expected test error")
})

server.get("/slow", async function (req: any, res: any) {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("home")
})

function sendV1(req: any, res: any, next: any) {
  res.send("goodbye: " + req.params.name)
  return next()
}

function sendV2(req: any, res: any, next: any) {
  res.send({ goodbye: req.params.name })
  return next()
}

server.get(
  "/goodbye/:name",
  restify.plugins.conditionalHandler([
    { version: "1.1.3", handler: sendV1 },
    { version: "2.0.0", handler: sendV2 }
  ])
)

const port = process.env.PORT
server.listen(port, function () {
  console.log("%s listening at %s", server.name, server.url)
})
