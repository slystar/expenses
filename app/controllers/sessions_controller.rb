class SessionsController < ApplicationController
    def new
    end

    def create
	user = User.find_by_user_name(params[:user_name].downcase)
	if user && user.authenticate(params[:password])
	    login(user)
	    redirect_to menu_path, :notice => "Logged in"
	else
	    flash.now[:error] = 'Invalid user/password combination'
	    render 'new'
	end
    end

    def destroy
	session[:user_id] = nil
	session[:user_name] = nil
	redirect_to login_path, :notice => "Logged out"
    end
end
