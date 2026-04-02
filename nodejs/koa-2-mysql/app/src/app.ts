import Koa from "koa"
import Router from "@koa/router"
import bodyParser from "koa-bodyparser"
import mysql, { Connection } from "mysql"
import mysql2 from "mysql2"

const mysqlConfig = {
  host: "mysql",
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE
}

const app = new Koa()
const router = new Router()
const port = process.env.PORT

app.use(bodyParser())

router.get("/", async (ctx: any) => {
  ctx.body = `
    <h1>Koa MySQL test app</h1>
    <ul>
      <li><a href="/slow">GET /slow</a></li>
      <li><a href="/error">GET /error</a></li>
      <li><a href="/mysql-query">GET /mysql-query</a></li>
      <li><a href="/mysql2-query">GET /mysql2-query</a></li>
    </ul>
  `
})

router.get("/error", async (_ctx: any) => {
  throw new Error("Expected test error!")
})

router.get("/slow", async (ctx: any) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  ctx.body = "Well, that took forever!"
})

router.get("/mysql-query", async (ctx: any) => {
  await dummyQuery(mysql)

  ctx.body = "MySQL query received!"
})

router.get("/mysql2-query", async (ctx: any) => {
  await dummyQuery(mysql2)

  ctx.body = "MySQL2 query received!"
})

function dummyQuery(mysqlClient: any) {
  let connection: Connection

  return new Promise((resolve, reject) => {
    connection = mysqlClient.createConnection(mysqlConfig)

    connection.connect()

    connection.query("SELECT 1 + 1 AS solution", (err, rows, _fields) => {
      if (err) reject(err)
      resolve(rows[0].solution)
    })
  }).finally(() => connection.end())
}

app.use(router.routes()).use(router.allowedMethods())

app.listen(port)
console.log(`Example app listening on port ${port}`)
