class UsersController < ApplicationController
  def index
    @users = db[:users]
  end

  def create
    @users = db[:users]
    user_params = params[:user]
    @users.insert(:name => user_params[:name], :email => user_params[:email])
    redirect_to users_path, :notice => "New user created"
  end

  def destroy
    @users = db[:users]
    user = @users.where(:id => params[:id])
    user_name = user.first[:name]
    user.delete
    redirect_to users_path, :notice => "User '#{user_name}' has been deleted!"
  end

  private

  # Quick and dirty method of creating a database connection
  def db
    @db ||= SequelRails.setup(Rails.env)
  end
end
