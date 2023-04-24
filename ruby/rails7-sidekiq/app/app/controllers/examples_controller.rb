class ExamplesController < ApplicationController
  def slow
    sleep 3
  end

  def error
    raise "This is a Rails error!"
  end

  def error_reporter
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    render :html => "An error has been reported through the Rails error reporter"
  end
end
