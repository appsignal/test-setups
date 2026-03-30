import Koa, { Context } from "koa"
import Router from "@koa/router"
import { connect, PostCollection } from "./db"

const app = new Koa()
const router = new Router()
const port = process.env.PORT

connect()
  .then(client => {
    const Posts = PostCollection(client)

    router.get("/", async (ctx: Context) => {
      const posts = await Posts.find().toArray()
      ctx.body = `
        <h1>Koa Mongo test app</h1>
        <ul>
          <li><a href="/slow">GET /slow</a></li>
          <li><a href="/error">GET /error</a></li>
        </ul>
        <p>Posts: ${JSON.stringify(posts)}</p>
      `
    })

    router.get("/error", (_ctx: Context) => {
      throw new Error("Expected test error")
    })

    router.get("/slow", async (ctx: Context) => {
      await new Promise((resolve) => setTimeout(resolve, 3000))

      ctx.body = "Well, that took forever!"
    })

    app.use(router.routes()).use(router.allowedMethods())

    app.listen(port)
    console.log(`Example app listening on port ${port}`)
  })
  .catch(err => {
    console.log(err)
    process.exit(1)
  })
