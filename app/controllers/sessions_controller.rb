class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      sign_in(user)
      redirect_to root_url, :notice => "Logged in"
    else
      flash.now.alert = "Invalid user or password"
      render "new"
    end
  end

  def destroy
    sign_out
    redirect_to root_url, :notice => "Logged out"
  end
end
