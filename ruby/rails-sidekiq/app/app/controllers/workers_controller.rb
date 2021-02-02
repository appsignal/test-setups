class WorkersController < ApplicationController
  WORKERS = [
    ErrorWorker,
    PerformanceWorker
  ].freeze

  def index
    @worker_types = WorkersController::WORKERS.map { |w| w.name }
    render :index
  end

  def queue
    future = params[:time] == "future"
    args =
      case params[:worker]
      when "ErrorWorker"
        ["Error test"]
      when "PerformanceWorker"
        ["Performance test"]
      else
        raise "Foo"
      end

    worker = WORKERS.find { |w| w.name == params[:worker] }
    if future
      worker.perform_in(5.minutes.from_now, *args)
    else
      worker.perform_async(*args)
    end
    redirect_to({ :action => :index }, :notice => "Worker queued")
  end
end
