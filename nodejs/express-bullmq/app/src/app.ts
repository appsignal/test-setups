import express from "express"
import { expressErrorHandler } from "@appsignal/nodejs"
import { Job, Queue, Worker } from "bullmq"
import { sampleJobProcessor } from "./worker"

const connection = {
  host: "redis",
  port: 6379
}

const processQueue = new Queue('process', {connection});
processQueue.obliterate({force: true});

const externalQueue = new Queue('external', {connection});
externalQueue.obliterate({force: true});

new Worker('process', sampleJobProcessor("server process"), {connection});

const app = express()
app.use(express.urlencoded({ extended: true }))

app.get("/", (_req: any, res: any) => {
  res.send(`<html><body>
    <h1>Express app with BullMQ</h1>
    <ul>
      <li><a href="/error">Error</a></li>
      <li><a href="/slow">Slow</a></li>
      <li><a href="/queue/external">Queue a job to be processed by an external worker</a></li>
      <li><a href="/queue/process">Queue a job to be processed within the server process</a></li>
    </ul>
  </body></html>`)
})

function sampleName() {
  const names = ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Hank', 'Ivy', 'Jack'];
  return names[Math.floor(Math.random() * names.length)];
}

async function addSampleJob(queue: Queue): Promise<Job> {
  const name = sampleName();
  const jobName = `cookies for ${name}`;
  return await externalQueue.add(jobName, { name: name }, { delay: 5000 });
}

function addQueueRequestHandler(queue: Queue) {
  return async (req: any, res: any, next: any) => {
    try {
      const job = await addSampleJob(queue);
      res.send(`Job ${job.id} ("${job.name}") added to queue ${queue.name}`);
    } catch (e) {
      next(e)
    }
  }
}

app.get("/queue/external", addQueueRequestHandler(externalQueue))

app.get("/queue/process", addQueueRequestHandler(processQueue))

app.get("/error", (_req: any, _res: any) => {
  throw new Error("Expected test error!")
})

app.get("/slow", async (_req: any, res: any) => {
  await new Promise((resolve) => setTimeout(resolve, 3000))

  res.send("Well, that took forever!")
})

app.use(expressErrorHandler())

const port = 4001;

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
