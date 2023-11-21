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
end
