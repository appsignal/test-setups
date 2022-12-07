class JobsController < ApplicationController
  def show
    case params[:id]
    when "error"
      ErrorJob.new.deliver("error job")
    when "performance"
      PerformanceJob.new.deliver("performance job")
    end

    redirect_to :action => :index, :notice => "Job queued"
  end
end
