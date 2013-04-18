module SessionsHelper

    def sign_in(user)
	session[:user_id] = user.id
	self.current_user = user
    end

    def signed_in?
	!current_user.nil?
    end

    def current_user=(user)
	@current_user = user
    end

    def current_user
	@current_user
    end

    def current_user?(user)
	user == current_user
    end

    def login_required
	puts('-' * 40)
	p session
	puts('-' * 40)
	p current_user
	puts('-' * 40)
	p self.current_user
	puts('-' * 40)
	unless signed_in?
	    store_location
	    redirect_to login_url, notice: "Please log in."
	end
    end

    def sign_out
	@current_user = nil
	session[:user_id] = nil
    end

    def redirect_back_or(default)
	redirect_to(session[:return_to] || default)
	session.delete(:return_to)
    end

    def store_location
	session[:return_to] = request.url
    end
end
