class TestsController < ApplicationController
  def error
    raise "Error in the rails6-shoryuken app"
  end

  def slow
    sleep 3
  end

  def active_job_performance_job
    PerformanceJob.perform_later("ActiveJob PerformanceJob queued")
    render :html => "ActiveJob PerformanceJob queued, refresh to queue a new one!"
  end

  def active_job_error_job
    ErrorJob.perform_later("ActiveJob ErrorJob queued")
    render :html => "ActiveJob ErrorJob queued, refresh to queue a new one!"
  end

  def shoryuken_native_job
    NativeWorker.perform_async(:body => "Native Shoryuken job queued")
    render :html => "Native Shoryuken job queued, refresh to queue a new one!"
  end

  def shoryuken_batched_job
    # Enqueue several messages so Shoryuken is likely to deliver them to the
    # worker as a single batch, which is the case the batch instrumentation
    # handles.
    5.times do |i|
      BatchedWorker.perform_async(:body => "Batched Shoryuken job #{i} queued")
    end
    render :html => "Batched Shoryuken jobs queued, refresh to queue new ones!"
  end

  # Enqueue a native Shoryuken job onto the `downstream` queue, which only the
  # separately instrumented downstream service drains. In collector mode this
  # shows job trace propagation across two services.
  def cross_service_job
    DownstreamWorker.perform_async(:body => "Cross-service job queued")
    render :html => "Cross-service Shoryuken job queued, refresh to queue a new one!"
  end
end
