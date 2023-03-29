import { Pool } from "pg"
import express from "express"

const pgPool = new Pool()
const port = process.env.PORT

const app = express()
app.use(express.urlencoded({ extended: true }))

app.get("/", (_req: any, res: any) => {
  res.send("GET query received!")
})

app.get("/error", (req, res) => {
  throw new Error("Expected test error")
})

app.get("/slow", async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("Well, that took forever!")
})

app.get("/pg-query", (_req: any, res: any) => {
  pgPool.query("SELECT 1 + 1 AS solution", (err, result) => {
    if (err) {
      throw err
    }

    res.send(`QUERY received! Result: ${result.rows[0]}`)
  })
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
