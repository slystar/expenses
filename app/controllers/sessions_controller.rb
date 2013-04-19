class SessionsController < ApplicationController
    def new
    end

    def create
	user = User.find_by_user_name(params[:user_name].downcase)
	if user && user.authenticate(params[:password])
	    session[:user_id] = user.id
	    redirect_to menu_path, :notice => "Logged in"
	else
	    flash.now[:error] = 'Invalid user/password combination'
	    render 'new'
	end
    end

    def destroy
	session[:user_id] = nil
	redirect_to login_path, :notice => "Logged out"
    end
end
