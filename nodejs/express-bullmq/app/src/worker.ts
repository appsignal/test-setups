import { Job, Worker } from "bullmq"

const connection = {
  host: "redis",
  port: 6379
}

const alreadyFailedJobs = new Set<string>();

export function sampleJobProcessor(context: string): (job: Job) => Promise<void> {
  return async function processSampleJob(job: Job) {
    console.log(`Processing job ${job.id} ("${job.name}") in ${context} with data:`, job.data);

    if (job.id && job.data.fail === "once" && !alreadyFailedJobs.has(job.id)) {
      alreadyFailedJobs.add(job.id);
      console.log(`Job ${job.id} failed!`);
      throw new Error(`Job ${job.id} failed!`);
    } else {
      console.log(`Job ${job.id} succeeded!`);
    }
  }
}

if (require.main === module) {
  new Worker('external', sampleJobProcessor("worker process"), {connection});
}
