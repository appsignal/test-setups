require "sinatra"
require "sidekiq"
require "appsignal"

Appsignal.load(:sinatra)
Appsignal.start

require_relative "jobs"

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV.fetch("REDIS_URL", "redis://redis:6379") }
end

DEFAULT_COUNT = 200_000
DEFAULT_BATCH_SIZE = 5_000

get "/" do
  enabled = Appsignal.config[:enable_job_enqueue_instrumentation]

  <<~HTML
    <h1>Sidekiq enqueue memory</h1>

    <p>
      Enqueue instrumentation is currently
      <strong>#{enabled ? "on" : "off"}</strong>
      (APPSIGNAL_ENABLE_JOB_ENQUEUE_INSTRUMENTATION).
    </p>

    <p>
      Starting a run queues a FanOutJob. The worker logs its resident memory as
      it pushes, so watch the container output rather than this page.
    </p>

    <ul>
      <li><a href="/fanout">Fan out #{DEFAULT_COUNT} jobs with push_bulk</a></li>
      <li><a href="/fanout?mode=perform_async&count=50000">Fan out 50000 jobs one at a time</a></li>
      <li><a href="/baseline">Baseline: a job that enqueues nothing</a></li>
    </ul>

    <p>
      Override with <code>?count=</code>, <code>?batch_size=</code> and
      <code>?mode=push_bulk|perform_async</code>.
    </p>
  HTML
end

get "/fanout" do
  count = params.fetch("count", DEFAULT_COUNT).to_i
  batch_size = params.fetch("batch_size", DEFAULT_BATCH_SIZE).to_i
  mode = params.fetch("mode", "push_bulk")

  FanOutJob.perform_async(count, batch_size, mode)

  "Queued FanOutJob: count=#{count} batch_size=#{batch_size} mode=#{mode}. " \
    "Watch the worker output."
end

# A run with nothing to enqueue, to separate the cost of the enqueue events
# from the cost of simply having a long lived transaction open.
get "/baseline" do
  FanOutJob.perform_async(0, DEFAULT_BATCH_SIZE, "push_bulk")

  "Queued an empty FanOutJob. Watch the worker output."
end
