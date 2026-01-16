class JobsController < ApplicationController
  DELAY_DURATION = 15.seconds

  def index
    render :index
  end

  def queue
    job_name = params[:job]
    future = params[:future] == "true"

    case job_name
    when "ActiveJobErrorJob"
      if future
        ActiveJobErrorJob.set(:wait => DELAY_DURATION).perform_later("Error test")
      else
        ActiveJobErrorJob.perform_later("Error test")
      end
    when "ActiveJobPerformanceJob"
      if future
        ActiveJobPerformanceJob.set(:wait => DELAY_DURATION).perform_later("Performance test")
      else
        ActiveJobPerformanceJob.perform_later("Performance test")
      end
    when "ErrorJob"
      if future
        ErrorJob.new.delay(:run_at => DELAY_DURATION.from_now).deliver_async("Error test")
      else
        ErrorJob.new.deliver_async("Error test")
      end
    when "PerformanceJob"
      if future
        PerformanceJob.new.delay(:run_at => DELAY_DURATION.from_now).deliver_async("Performance test")
      else
        PerformanceJob.new.deliver_async("Performance test")
      end
    end

    redirect_to({ :action => :index }, :notice => "Job queued")
  end
end
