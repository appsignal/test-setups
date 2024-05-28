import { Job, Worker } from "bullmq"

const connection = {
  host: "redis",
  port: 6379
}

export function sampleJobProcessor(context: string): (job: Job) => Promise<void> {
  return async function processSampleJob(job: Job) {
    console.log(`Processing job ${job.id} ("${job.name}") in ${context} with data:`, job.data);
  }
}

if (require.main === module) {
  new Worker('external', sampleJobProcessor("worker process"), {connection});
}
