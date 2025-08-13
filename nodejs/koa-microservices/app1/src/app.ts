import Koa from "koa"
import Router from "@koa/router"
import bodyParser from "koa-bodyparser"
import fetch from "node-fetch"
import { setTag } from "@appsignal/nodejs"

const app = new Koa()
const router = new Router()
const port = process.env.PORT

app.use(bodyParser())

router.get("/", async (ctx: any) => {
  ctx.body = "GET query received!"
})

router.get("/error", async (_ctx: any) => {
  throw new Error("Expected test error!")
})

router.get("/slow", async (ctx: any) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  ctx.body = "Well, that took forever!"
})

router.get("/remote/app2", async (ctx: any) => {
  setTag("original_app_id", "app1");
  try {
    const response = await fetch("http://app2:4002/incoming/app2")
    const data = await response.text()
    ctx.body = data
  } catch (error) {
    ctx.status = 500
    ctx.body = `Error making request to app2: ${error}`
  }
})

router.get("/incoming/app1", async (ctx: any) => {
  setTag("remote_app_id", "app1");

  ctx.body = "Request received by app1!"
})

app.use(router.routes()).use(router.allowedMethods())

app.listen(port)
console.log(`Example app listening on port ${port}`)
