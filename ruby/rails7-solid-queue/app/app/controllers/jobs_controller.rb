class JobsController < ApplicationController
  def show
    case params[:id]
    when "error"
      ErrorJob.perform_later("error job")
    when "performance"
      PerformanceJob.perform_later("performance job")
    end

    redirect_to jobs_path, :notice => "Job queued"
  end
end
