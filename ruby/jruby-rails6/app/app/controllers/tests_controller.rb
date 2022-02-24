class TestsController < ApplicationController
  def error
    raise "Error in the jruby-rails6 app"
  end

  def slow
    sleep 3
  end
end
