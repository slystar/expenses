class ExpensesController < ApplicationController
    before_filter :login_required

    # GET /expenses
    # GET /expenses.json
    def index
	# Params
	date_purchased_months_ago=params[:date_purchased_months_ago]
	# Default values
	if date_purchased_months_ago.nil? or date_purchased_months_ago.empty?
	    date_purchased_months_ago=6
	else
	    date_purchased_months_ago=date_purchased_months_ago.to_i
	end
	# Filters
	@filters={}
	@filters[:date_purchased_months_ago]=date_purchased_months_ago
	# Get last 6 months
	@expenses = Expense.includes(:store).includes(:pay_method).includes(:reason).includes(:group).includes(:user).find(:all, :conditions => ["date_purchased > ?",@filters[:date_purchased_months_ago].month.ago.to_date], :order => "date_purchased desc")


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
end
