class TestsController < ApplicationController
  def error
    raise "Error in the rails6-shoryuken app"
  end

  def slow
    sleep 3
  end

  def job
    DefaultJob.perform_later("TestsController async job")
  end
end
