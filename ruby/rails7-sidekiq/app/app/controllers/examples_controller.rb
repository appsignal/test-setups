class ExamplesController < ApplicationController
  def slow
    existing_user_count = User.count
    if params[:create]
      User.destroy_all
      300.times do |i|
        user = User.create!(:name => "User #{existing_user_count + i}")
        100.times do |link_i|
          link = Link.create!(:link => "Link #{link_i}", :user => user)
        end
      end
    end
    @users = User.all
    # sleep 3
  end

  def error
    raise "This is a Rails error!"
  end
end
