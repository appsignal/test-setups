class ExamplesController < ApplicationController
  def index
    session[:user_id] = :some_user_id_123
    session[:menu] = { :state => :open, :view => :full }
  end

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

  def queries
    user_count = User.count
    User.destroy_all if user_count > 10_000

    2.times do |i|
      User.create!(:name => "User ##{user_count + i}")
    end
    @users = User.all
  end
end
