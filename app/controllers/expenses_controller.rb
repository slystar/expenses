class ExpensesController < ApplicationController
    before_filter :login_required
    before_filter :check_for_user_payments, :only => :menu

    # Method to check for user_payments
    def check_for_user_payments
	# Check if any user_payments require approval
	if current_user.needs_to_approve_user_payments?
	    redirect_to "#{user_payments_path}/approve"
	end
    end

    # GET /expenses
    # GET /expenses.json
    def index
	# Variables
	@start_time=Time.now
	# Filters
	filter_names=[:filter_pay_method, :filter_reason, :filter_store, :filter_user]
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
		# Exception for user
		col_name='user_name' if filter_name == 'user'
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
	@user_names=@expenses.map{|e| [e.user.user_name,e.user.id]}.sort{|a,b| a[0]<=>b[0]}.uniq

	# set return_to
	session[:return_to] = request.url

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
	# Get previous expense info
	prev_expense=session[:current_expense]
	prev_last_date_purchased=session[:last_date_purchased]
	# Check for previous expense
	if prev_expense.nil?
	    @expense = Expense.new
	else
	    @expense = prev_expense
	    session[:current_expense]=nil
	end
	# Set amount to nil, we want user to fill something
	@expense.amount=nil
	# Set last date purchased
	if not prev_last_date_purchased.nil?
	    @expense.date_purchased=prev_last_date_purchased
	end

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
	# Check if expense if processed
	if @expense.process_flag
	    @field_restrictions=true
	end
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
		    # Save last date purchased
		    session[:last_date_purchased]=@expense.date_purchased
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
	@balances=current_user.balances
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
	ih.import_data(file_handle,ic,user_id)
	# Save info for view
	@ih=ih
	# Redirect
	#redirect_to :process_imports, :notice => "File #{file_original_name} successfully processed"
    end

    # List imported records that need to be processed
    def process_imports
	# Get user
	user_id=session[:user_id]
	# Get records to process
	@records=ImportDatum.imports_to_process(user_id).includes(:import_history).includes(:import_config)
	#@debug_info=@records.first.import_config.to_yaml if @records
    end

    # Process single imported record
    def process_import
	# Variables
	found_info=[]
	warnings=[]
	# Get id
	id_to_process=params[:id]
	# Get user
	user_id=session[:user_id]
	# Try to find record
	record=ImportDatum.find(id_to_process)
	# Check if it's the correct user
	if user_id != record.user_id
	    redirect_to :process_imports, :alert => 'Error: this is not your record' and return
	end
	# Create expense object
	@expense = Expense.new
	# Get attribute names
	attr_names=@expense.attribute_names
	# Supported additional attributes
	supported_additional_attr=[:store, :pay_method, :reason, :group]
	# Add information
	record.mapped_fields.each do |sym,val|
	    # Check if it's a direct attribute
	    if attr_names.include?(sym.to_s)
		# Notice
		found_info << "Found #{sym}: #{val}"
		@expense[sym]=val
	    elsif supported_additional_attr.include?(sym)
		begin
		# Try to convert to class
		klass=Object.const_get(sym.to_s.camelcase)
		rescue => e
		    # Redirect with error
		    redirect_to :process_imports, :alert => "Error: unknown class -> '#{sym}' in mapped_fields for record id: #{id_to_process}" and return
		end
		# Try to find record
		klass_record=klass.where(["lower(name) = ?",val.chomp.downcase]).first
		# Add if found
		if klass_record.nil?
		    # Create object
		    klass_object=klass.new
		    klass_object.name=val.capitalize
		    # Try to save object
		    if klass_object.save
			# Message
			warnings << "Created #{klass}: #{val}"
			# Set store
			@expense.send("#{sym}_id=",klass_object.id)
		    else
			# Message
			warnings << "Could not find #{klass}: #{val}"
		    end
		else
		    # Exception for store
		    if klass and klass.name == 'Store'
			# Try to get root store
			root_store=klass_record.root_store
			# Check if we mapped
			if root_store != klass_record
			    warnings << "Found parent #{klass}: '#{root_store.name}' of child '#{klass_record.name}'"
			end
			# Set new store
			klass_record=root_store
		    end
		    # Check if we mapped
		    # Add flash
		    found_info << "Found #{klass}: #{klass_record.name}"
		    @expense.send("#{sym}_id=",klass_record.id)
		end
	    else
		# Unknown attribute
		redirect_to :process_imports, :alert => "Error: unknown attribute -> '#{sym}' in record id: #{id_to_process}" and return
	    end
	    # Set flash variables
	    flash[:found]=found_info unless found_info.empty?
	    flash[:warning]=warnings unless warnings.empty?
	    # Get count
	    @records_total=ImportDatum.imports_to_process(user_id).includes(:import_history).includes(:import_config).size
	end
	# Add Pay method
	@expense.pay_method_id=record.import_config.pay_method_id
	# Get required info
	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').where(:hidden => false).all
	# Send additional info
	@record_id=record.id
	@original_store_id=@expense.store_id
    end

    # Add single imported record as expense
    def create_from_imported
	# Get params
	expense=params[:expense]
	import_id=params[:import_id]
	original_store_id=params[:original_store_id].to_i
	user_id=session[:user_id]
	notices=[]
	# Create expense object
	@expense = Expense.new(expense)
	# Set user
	@expense.user_id=user_id
	# Get import_datum object
	id=ImportDatum.find(import_id)

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
		if id.approve(@expense)
		    # Check original_store_id
		    if child_store=Store.where("id=?",original_store_id).first
			# Check if we need to map store
			if original_store_id != @expense.store_id
			    # Map store
			    child_store=Store.find(original_store_id)
			    # Set parent
			    child_store.parent_id=@expense.store_id
			    # Save
			    child_store.save!
			    # Add notice
			    notices.push("Store '#{@expense.store.name}' is now parent of '#{child_store.name}'")
			end
		    end
		    # Look for next record
		    next_import=ImportDatum.next_import_for_user(user_id,import_id)
		    # Prepare notice
		    notices.push('Expense was successfully created.')
		    # Check if we have a new record
		    if next_import
			format.html { redirect_to "#{expenses_path}/process_import/#{next_import.id}", notice: notices }
		    else
			format.html { redirect_to "#{expenses_path}/process_imports", notice: notices }
		    end
		else
		    @pay_methods = PayMethod.order("name").all
		    @reasons = Reason.order("name").all
		    @stores = Store.order("name").all
		    @groups = Group.order('name').where(:hidden => false).all
		    # Send import record id
		    @record_id=import_id
		    format.html { render action: "process_import" }
		end
	    end
	end
    end

    # Process imported records, multiple records at once
    def process_imports_multi
	# Reference: http://railscasts.com/episodes/198-edit-multiple-individually?view=asciicast
	# Variables
	@new_expenses=[]
	# Get required data
	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').where(:hidden => false).all
	# Get user
	user_id=session[:user_id]
	# Get records to process
	records=ImportDatum.where(:user_id => user_id)
	# Loop over records
	records.each do |rec|
	    # Get attributes
	    attr=rec.mapped_fields
	    store_id=Store.find(:first, :conditions => {:name => attr[:store]})
	    @debug_info=['aaa',attr,store_id]
	    # We need to create new expenses
	    @new_expenses.push(Expense.new(attr))
	end
	@records=records
    end

    # Add multiple imported records as expenses
    def add_imported_expenses
	@debug_info=params
    end

    # Add method to display information on entered expenses that can be processed(divide the expenses among group members)
    def process_data
	# Get expenses to process
	@expenses=Expense.where(:process_flag => false).includes(:user).includes(:store).includes(:pay_method).includes(:reason).includes(:group).order(:user_id).order(:date_purchased)
    end

    # Method to process all expenses now
    def process_all_now
	# Variables
	count_good=0
	count_bad=0
	# Loop over each record (this could be a list of id numbers from previous page but let's keep it simple)
	@expenses=Expense.where(:process_flag => false).order(:user_id).order(:date_purchased).each do |e|
	    # Process this record
	    if e.process(current_user.id)
		# Add to count
		count_good += 1
	    else
		# Add to count
		count_bad += 1
	    end
	end
	redirect_to menu_path, notice: "All expenses processed, #{count_good} OK, #{count_bad} errors"
    end
end
