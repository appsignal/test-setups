import Fastify from "fastify"
import pino from "pino"
import { Appsignal, AppsignalPinoTransport } from "@appsignal/nodejs"

const port = Number(process.env.PORT)

const logger = pino(AppsignalPinoTransport({client: Appsignal.client, group: "application"}))

const fastify = Fastify({
  logger: logger
})

fastify.get("/", function (_request, reply) {
  reply.send({ hello: "world" })
})

fastify.get("/error", function (_request, reply) {
  throw new Error("EXPECTED ERROR!")

  reply.send({ never: "gets" })
})

fastify.get("/slow", async function (_request, reply) {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  reply.send({ got: "slow" })
})

fastify.listen({ port, host: "0.0.0.0" }, function (err, _address) {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }

  console.log(`Example app listening on port ${port}`)
})
