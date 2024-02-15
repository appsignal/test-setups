class JobsController < ApplicationController
  def slow
    PerformanceJob.perform_later("Slow argument", :options => "something")
    Rails.logger.warn "Queued PerformanceJob"

    redirect_to root_path, :notice => "Queued PerformanceJob"
  end

  def error
    ErrorJob.perform_later("Error argument", :options => "something")
    Rails.logger.warn "Queued ErrorJob"
    redirect_to root_path, :notice => "Queued ErrorJob"
  end
end
