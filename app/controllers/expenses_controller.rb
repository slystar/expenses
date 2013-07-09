class ExpensesController < ApplicationController
    before_filter :login_required

    # GET /expenses
    # GET /expenses.json
    def index
	# Variables
	@start_time=Time.now
	@debug_info=[]
	# Filters
	filter_names=[:filter_pay_method, :filter_reason, :filter_store]
	# Params
	date_purchased_months_ago=params[:date_purchased_months_ago]

	# Default values
	if date_purchased_months_ago.nil? or date_purchased_months_ago.empty?
	    date_purchased_months_ago=6
	else
	    date_purchased_months_ago=date_purchased_months_ago.to_i
	end

	# Set Filters variable for view
	@filters={}
	@filters[:date_purchased_months_ago]=date_purchased_months_ago

	# Prepare Data
	@expenses = Expense.includes(:store).includes(:pay_method).includes(:reason).includes(:group).includes(:user)
	# Loop over filter names
	filter_names.each do |filter_name|
	    # Get filter value
	    filter_value=params[filter_name]
	    # Check if we have a filter_value to process
	    unless filter_value.nil? or filter_value.empty?
		# Add to filters variable
		@filters[filter_name]=filter_value
		# Get column name
		col_name=filter_name.to_s.gsub('filter_','').gsub(/$/,'_id')
		# Filter data
		@expenses=@expenses.where("#{col_name}" => filter_value)
	    end
	end
	# Get data
	@expenses = @expenses.find(:all, :conditions => ["date_purchased > ?",@filters[:date_purchased_months_ago].month.ago.to_date], :order => "user_id, date_purchased desc")
	

	# Get data for filters
	@pay_method_names=@expenses.map{|e| [e.pay_method.name,e.pay_method.id]}.sort{|a,b| a[0]<=>b[0]}.uniq
	@reason_names=@expenses.map{|e| [e.reason.name,e.reason.id]}.sort{|a,b| a[0]<=>b[0]}.uniq
	@store_names=@expenses.map{|e| [e.store.name,e.store.id]}.sort{|a,b| a[0]<=>b[0]}.uniq

	@debug_info.push([params, @filters]).flatten

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @expenses }
	end
    end

    # GET /expenses/1
    # GET /expenses/1.json
    def show
	@expense = Expense.find(params[:id])
	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').where(:hidden => false).all

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @expense }
	end
    end

    # GET /expenses/new
    # GET /expenses/new.json
    def new
	# Get previous expense
	prev_expense=session[:current_expense]
	# Check for previous expense
	if prev_expense.nil?
	    @expense = Expense.new
	else
	    @expense = prev_expense
	    session[:current_expense]=nil
	end
	# Set amount to nil, we want user to fill something
	@expense.amount=nil

	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').where(:hidden => false).all

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @expense }
	end
    end

    # GET /expenses/1/edit
    def edit
	@expense = Expense.find(params[:id])
	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').where(:hidden => false).all
    end

    # POST /expenses
    # POST /expenses.json
    def create
	@expense = Expense.new(params[:expense])
	# Set user
	@expense.user_id=session[:user_id]

	# Get submit button pressed
	submit_button=params[:commit]
	# Process submit button
	if submit_button == "Add Pay Method"
	    # Save existing objects in session
	    session[:current_expense]=@expense
	    # Redirect to add
	    redirect_to "#{pay_methods_path}/new"
	elsif submit_button == "Add Reason"
	    # Save existing objects in session
	    session[:current_expense]=@expense
	    # Redirect to add
	    redirect_to "#{reasons_path}/new"
	elsif submit_button == "Add Store"
	    # Save existing objects in session
	    session[:current_expense]=@expense
	    # Redirect to add
	    redirect_to "#{stores_path}/new"
	else
	    respond_to do |format|
		if @expense.save
		    format.html { redirect_to "#{expenses_path}/new", notice: 'Expense was successfully created.' }
		    format.json { render json: @expense, status: :created, location: @expense }
		else
		    @pay_methods = PayMethod.order("name").all
		    @reasons = Reason.order("name").all
		    @stores = Store.order("name").all
		    @groups = Group.order('name').where(:hidden => false).all
		    format.html { render action: "new" }
		    format.json { render json: @expense.errors, status: :unprocessable_entity }
		end
	    end
	end
    end

    # PUT /expenses/1
    # PUT /expenses/1.json
    def update
	@expense = Expense.find(params[:id])

	respond_to do |format|
	    if @expense.update_attributes(params[:expense])
		format.html { redirect_to @expense, notice: 'Expense was successfully updated.' }
		format.json { head :ok }
	    else
		@pay_methods = PayMethod.order("name").all
		@reasons = Reason.order("name").all
		@stores = Store.order("name").all
		@groups = Group.order('name').where(:hidden => false).all
		format.html { render action: "edit" }
		format.json { render json: @expense.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /expenses/1
    # DELETE /expenses/1.json
    def destroy
	@expense = Expense.find(params[:id])
	@expense.destroy

	respond_to do |format|
	    format.html { redirect_to expenses_url }
	    format.json { head :ok }
	end
    end

    # GET /menu
    def menu
    end

    # Import
    def import
	@supported_configs=ImportConfig.select(:id).select(:title).select(:description).all
    end

    # File import
    def file_upload
	# Variables
	errors=[]
	# Get PARAMS
	file_info=params[:file_upload][:my_file]
	ic_id=params[:file_upload][:import_config]
	# Check if we have a file
	if file_info.nil?
	    # Add to errors
	    errors << "Missing file"
	else
	    # Get import file handle
	    file_handle=file_info.tempfile
	    # Get original filename
	    file_original_name=file_info.original_filename
	end
	# Check for config
	if ic_id.nil? or ic_id.empty?
	    # Add to errors
	    errors << "Please select an 'import config'"
	end
	# Check for errors
	if errors.size > 0
	    # Redirect to import
	    redirect_to :import, :alert => errors and return
	end
	# Get an import_history object
	ih=ImportHistory.new({:import_config_id => ic_id, :original_file_name => file_original_name})
	# Get current user
	user_id=session[:user_id]
	# Set user
	ih.user_id=user_id
	# Save ImportHistory
	if not ih.save
	    # Error
	    redirect_to :import, :alert => ih.errors.messages and return
	end
	# Get import_config
	ic=ih.import_config
	# Import data
	if not ih.import_data(file_handle,ic,user_id)
	    # Error
	    #redirect_to :import, :alert => ih.errors.messages and return
	    @debug_info=ih
	end
	# TEMP
	@supported_configs=ImportConfig.select(:id).select(:title).select(:description).all
	render :import
    end
end
