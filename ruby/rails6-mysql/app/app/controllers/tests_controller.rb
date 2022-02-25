class TestsController < ApplicationController
  def error
    raise "Error in the rails6-mysql app"
  end

  def slow
    sleep 3
  end
end
