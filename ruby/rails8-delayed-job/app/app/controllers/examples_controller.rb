class ExamplesController < ApplicationController
  def index
  end

  def slow
    sleep 3
  end

  def error
    raise ReportError, "This is a Rails error!"
  end
end
