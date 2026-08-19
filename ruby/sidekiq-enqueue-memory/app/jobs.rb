require "sidekiq"
require_relative "lib/memory_sampler"

# Pushed in bulk by FanOutJob and never executed.
#
# The "sink" queue is deliberately left out of the worker's queue list, so these
# pile up in Redis instead of running. That mirrors the customer's staging dyno,
# where Sidekiq "seems to just back up", and it keeps the measurement about the
# enqueue path rather than about whatever the jobs themselves would allocate.
class SinkJob
  include Sidekiq::Job
  sidekiq_options :queue => "sink", :retry => false

  def perform(_index); end
end

# Enqueues a large number of jobs from inside a running Sidekiq job.
#
# This is the shape that matters. Version 4.9.0 of the gem records an
# `enqueue.sidekiq` event on the transaction that is currently active, and the
# Sidekiq hook installs the client middleware on the server as well as the
# client, precisely so that jobs enqueueing jobs are covered. Those events are
# pushed onto a Vec that is only drained when the transaction completes, so a
# job that fans out and keeps running accumulates one event per job it pushes.
#
# Enqueueing from a web request would exercise the same middleware, but the
# customer's growth was on a worker dyno, so the fan out belongs in a job.
class FanOutJob
  include Sidekiq::Job
  sidekiq_options :queue => "fanout", :retry => false

  def perform(count, batch_size, mode)
    sampler = MemorySampler.new("fanout")
    sampler.checkpoint(0)

    enqueued = 0
    while enqueued < count
      this_batch = [batch_size, count - enqueued].min

      case mode
      when "push_bulk"
        push_bulk(enqueued, this_batch)
      when "perform_async"
        this_batch.times { |offset| SinkJob.perform_async(enqueued + offset) }
      else
        raise ArgumentError, "unknown mode #{mode.inspect}, expected push_bulk or perform_async"
      end

      enqueued += this_batch
      sampler.checkpoint(enqueued)
    end

    sampler.summary(enqueued)
  end

  private

  def push_bulk(offset, size)
    Sidekiq::Client.push_bulk(
      "class" => SinkJob,
      "queue" => "sink",
      "args" => Array.new(size) { |index| [offset + index] }
    )
  end
end
