module SessionsHelper

    def sign_in(user)
	session[:user_id] = user.id
	session[:user_token] = get_user_token(user.id)
	session[:user_name] = user.user_name
    end

    def signed_in?
	# Get info
	user_id=session[:user_id]
	user_token=session[:user_token]
	# Check session
	if user_id.nil? or user_token.nil?
	    return false
	elsif get_user_token(user_id) == user_token
	    return true
	else
	    return false
	end
    end

    def login_required
	unless signed_in?
	    store_location
	    redirect_to login_url, notice: "Please log in."
	end
    end

    def admin_required
	unless is_admin?
	    target_url=request.url
	    redirect_back_or(menu_path,"#{target_url} requires Admin role.")
	end
    end

    def is_admin?
	# Get user id
	user_id=session[:user_id]
	# Check for admin role
	Role.find(:first,:conditions => {:name => 'Admin'}).user_ids.include?(user_id)
    end

    def sign_out
	session[:user_id] = nil
	session[:user_token] = nil
    end

    def redirect_back_or(path=login_path, notice=nil)
	# Get session info
	url=session[:return_to] || path
	# Erase session
	session.delete(:return_to)
	# Check if notice
	if notice
	    # Redirect with notice
	    redirect_to url, notice: notice
	else
	    # Redirect without notice
	    redirect_to url, notice: notice
	end
    end

    def store_location
	session[:return_to] = request.url
    end

    private

    # Method to generate user_token
    def get_user_token(user_id)
	# Set salt string
	salt_value='$abieSE92imHMZD'
	# Prepare string
	string="#{salt_value}-#{user_id}"
	# Hash string
	hash=Digest::SHA2.hexdigest(string)
	# Return data
	return hash
    end
end
