class WorkersController < ApplicationController
  # Each entry is [type, job, test]. The type selects how the job is enqueued:
  #
  # - :que        native Que job enqueued with `.enqueue`, which records an
  #               `enqueue.que` event on this request.
  # - :que_bulk   several native Que jobs enqueued inside a `Que::Job.bulk_enqueue`
  #               block, which records a single `bulk_enqueue.que` event.
  # - :active_job Active Job (adapter :que) enqueued with `perform_later`. This
  #               records an `enqueue.active_job` event instead; the underlying
  #               Que enqueue is suppressed so it's recorded once.
  # - :mailer     a mailer delivered with `deliver_later` (also `enqueue.active_job`).
  TESTS = [
    [:que, PerformanceJob, :default],
    [:que, ErrorJob, :default],
    [:que_bulk, PerformanceJob, :default],
    [:active_job, ActiveJobPerformanceWorker, :default],
    [:active_job, ActiveJobErrorWorker, :default],
    [:mailer, PerformanceMailer, :default],
    [:mailer, ErrorMailer, :default],
  ].freeze

  def index
    @worker_tests = TESTS
    render :index
  end

  def queue
    worker_param = params[:worker]
    # The same job appears under more than one type (e.g. `:que` and
    # `:que_bulk`), so match on both the type and the job name.
    type, worker, _test = TESTS.find do |(entry_type, job, _test)|
      entry_type.to_s == params[:type] && job.name == worker_param
    end
    args = ["#{worker_param} test"]

    send("handle_#{type}", worker, args)

    redirect_to({ :action => :index }, :notice => "Worker queued")
  end

  # Enqueue a native Que job onto the `downstream` queue, which only the
  # separately instrumented downstream service drains. In collector mode this
  # shows job trace propagation across two services.
  def cross_service
    DownstreamJob.enqueue("Cross-service test", :job_options => { :queue => "downstream" })
    redirect_to({ :action => :index }, :notice => "Cross-service job queued")
  end

  private

  def handle_que(worker, args)
    worker.enqueue(*args)
  end

  def handle_que_bulk(worker, args)
    worker.bulk_enqueue do
      worker.enqueue(*args)
      worker.enqueue(*args)
      worker.enqueue(*args)
    end
  end

  def handle_active_job(worker, args)
    worker.perform_later(*args)
  end

  def handle_mailer(worker, args)
    worker.test(*args).deliver_later
  end
end
