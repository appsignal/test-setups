class PagesController < ApplicationController
  def slow
    sleep 3
    render :plain => "That took a while!"
  end

  def error
    raise "This is a Rails error!"
  end
end
