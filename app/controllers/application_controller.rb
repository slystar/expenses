class ApplicationController < ActionController::Base
    protect_from_forgery

    # Force signout to prevent CSRF attacks
    def handle_unverified_request
	sign_out
	super
    end

    private

    # Method to login user
    def login(user)
	session[:user_id] = user.id
	session[:user_name] = user.user_name
    end

    # Method to check for authenticated user
    def login_required
	if current_user.nil?
	    redirect_to login_path, notice: "Please log in."
	end
    end

    # Method to check for admin user
    def admin_required
	unless current_user.is_admin?
	    # Get url
	    target_url=request.url
	    redirect_to menu_path, notice: "#{target_url} requires admin role."
	end
    end

    # Method to get current user
    def current_user
	@current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    # Make current_user available in views
    helper_method :current_user
end
