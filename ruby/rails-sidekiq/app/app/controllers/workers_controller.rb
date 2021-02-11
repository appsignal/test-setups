class SidekiqInternalJSONParseErrorJob; end

class WorkersController < ApplicationController
  TESTS = [
    [:sidekiq, ErrorWorker, :default],
    [:sidekiq, PerformanceWorker, :default],
    [:active_job, ActiveJobErrorWorker, :default],
    [:active_job, ActiveJobPerformanceWorker, :default],
    [:mailer, ErrorMailer, :default],
    [:mailer, ErrorMailer, :with_args],
    [:mailer, PerformanceMailer, :default],
    [:mailer, PerformanceMailer, :with_args],
    [:sidekiq_internal, SidekiqInternalJSONParseErrorJob, :default],
    [:model, User, :delay],
    [:model, User, :delay_with_error]
  ].freeze
  DELAY_DURATION = 5.minutes

  def index
    @worker_tests = TESTS
    render :index
  end

  def queue
    worker_param = params[:worker]
    test_param = params[:test]
    future = params[:time] == "future"
    type, worker, _test = TESTS.find { |(_, worker, _test)| worker.name == worker_param }
    args =
      case worker_param
      when "ErrorWorker"
        ["Error test"]
      when "PerformanceWorker"
        ["Performance test"]
      when "ActiveJobErrorWorker"
        ["ActiveJob Error test"]
      when "ActiveJobPerformanceWorker"
        ["ActiveJob Performance test"]
      when "ErrorMailer"
        ["ActiveJob Error Mailer test"]
      when "PerformanceMailer"
        ["ActiveJob Performance Mailer test"]
      else
        ["Default args"]
      end

    send(
      "handle_#{type}",
      worker,
      :test => test_param,
      :args => args,
      :future => future
    )

    redirect_to({ :action => :index }, :notice => "Worker queued")
  end

  def handle_sidekiq(worker, args:, test:, future:)
    if future
      worker.perform_in(DELAY_DURATION.from_now, *args)
    else
      worker.perform_async(*args)
    end
  end

  def handle_active_job(worker, args:, test:, future:)
    if future
      worker.set(:wait => DELAY_DURATION).perform_later(*args)
    else
      worker.perform_later(*args)
    end
  end

  def handle_mailer(worker, args:, test:, future:)
    case test.to_sym
    when :with_args
      if future
        worker.with(*args).test.deliver_later(:wait => DELAY_DURATION)
      else
        worker.with(*args).test.deliver_later
      end
    else
      if future
        worker.test(*args).deliver_later(:wait => DELAY_DURATION)
      else
        worker.test(*args).deliver_later
      end
    end
  end

  def handle_sidekiq_internal(worker, args:, test:, future:)
    # Insert a bad JSON string that Sidekiq will error on parsing, triggering
    # the Ruby gem 3.0 error handler method of reporting errors to AppSignal.
    redis = Redis.new(:url => ENV["REDIS_URL"])
    redis.lpush("queue:default", "{ bad json }")
  end

  def handle_model(worker, args:, test:, future:)
    case test.to_sym
    when :delay
      user = User.create(:name => "John")
      if future
        user.delay_for(DELAY_DURATION).do_stuff!
      else
        user.delay.do_stuff!
      end
    when :delay_with_error
      user = User.create(:name => "John")
      if future
        user.delay_for(DELAY_DURATION).do_stuff_with_error!
      else
        user.delay.do_stuff_with_error!
      end
    else
      raise "Unknown test"
    end
  end
end
