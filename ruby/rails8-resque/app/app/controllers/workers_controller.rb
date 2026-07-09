class WorkersController < ApplicationController
  # Each entry is [type, job, test]. The type selects how the job is enqueued:
  #
  # - :resque     native Resque job enqueued with `Resque.enqueue`, which
  #               records an `enqueue.resque` event on this request.
  # - :active_job Active Job (adapter :resque) enqueued with `perform_later`.
  #               This records an `enqueue.active_job` event instead; the
  #               underlying Resque enqueue is suppressed so it's recorded once.
  # - :mailer     a mailer delivered with `deliver_later`, which enqueues an
  #               Active Job mailer job (also an `enqueue.active_job` event).
  TESTS = [
    [:resque, PerformanceJob, :default],
    [:resque, ErrorJob, :default],
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
    type, worker, _test = TESTS.find { |(_, job, _test)| job.name == worker_param }
    args = ["#{worker_param} test"]

    send("handle_#{type}", worker, args)

    redirect_to({ :action => :index }, :notice => "Worker queued")
  end

  # Enqueue a native Resque job onto the `downstream` queue, which only the
  # separately instrumented downstream service drains. In collector mode this
  # shows job trace propagation across two services.
  def cross_service
    Resque.enqueue(DownstreamJob, "Cross-service test")
    redirect_to({ :action => :index }, :notice => "Cross-service job queued")
  end

  private

  def handle_resque(worker, args)
    Resque.enqueue(worker, *args)
  end

  def handle_active_job(worker, args)
    worker.perform_later(*args)
  end

  def handle_mailer(worker, args)
    worker.test(*args).deliver_later
  end
end
