class ApplicationController < ActionController::Base
    protect_from_forgery

    # Force signout to prevent CSRF attacks
    def handle_unverified_request
	sign_out
	super
    end

    private

    # Method to check for authenticated user
    def login_required
	if current_user.nil?
	    redirect_to login_url, notice: "Please log in."
	end
    end

    # Method to get current user
    def current_user
	@current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    # Make current_user available in views
    helper_method :current_user
end
