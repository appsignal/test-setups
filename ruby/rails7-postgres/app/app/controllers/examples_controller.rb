class ExamplesController < ApplicationController
  def slow
    sleep 3
  end
  
  def error
    raise "This is a Rails error!"
  end
end
