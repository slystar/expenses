class UsersController < ApplicationController
    before_filter :login_required, :except => [:new, :create]
    before_filter :admin_required, :only => [:index]

    # GET /users
    # GET /users.json
    def index
	@users = User.all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @users }
	end
    end

    # GET /users/new
    # GET /users/new.json
    def new
	@user = User.new

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @user }
	end
    end

    # GET /users/1/edit
    def edit
	# Check if user is trying to edit someone else
	if current_user.id.to_i != params[:id].to_i
	    # Check for Admin
	    if not current_user.is_admin?
		redirect_to menu_path, alert: "You may only edit yourself."
	    end
	end
	@user = User.find(params[:id])
    end

    # POST /users
    # POST /users.json
    def create
	@user = User.new(params[:user])

	respond_to do |format|
	    if @user.save
		login(@user)
		format.html { redirect_to menu_path, notice: 'User was successfully created.' }
		format.json { render json: @user, status: :created, location: @user }
	    else
		format.html { render action: "new" }
		format.json { render json: @user.errors, status: :unprocessable_entity }
	    end
	end
    end

    # PUT /users/1
    # PUT /users/1.json
    def update
	error_msg=nil
	@user = User.find(params[:id])

	# Do not allow modification of following parameters
	[:user_name].each do |p|
	    # Remove paramter
	    if params[:user].delete(p)
		error_msg="Parameter: #{p} is not allowed to change"
	    end
	end

	# Get current password
	current_password=params[:custom][:current_password]
	# Verify existing password
	if not (@user && @user.authenticate(current_password))
	    error_msg="Wrong current password"
	end

	respond_to do |format|
	    if error_msg
		# Add errors
		@user.errors[:base] << error_msg
		format.html { render action: 'edit' }
	    elsif @user.update_attributes(params[:user])
		format.html { redirect_to menu_path, notice: 'User was successfully updated.' }
		format.json { head :ok }
	    else
		format.html { render action: "edit" }
		format.json { render json: @user.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
	# Not implemented yet
	redirect_to menu_path, alert: "Destroy not enabled"
    end
end
