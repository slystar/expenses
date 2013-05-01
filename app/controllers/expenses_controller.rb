class ExpensesController < ApplicationController
    before_filter :login_required, :except => [:new, :create]

    # GET /expenses
    # GET /expenses.json
    def index
	@expenses = Expense.all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @expenses }
	end
    end

    # GET /expenses/1
    # GET /expenses/1.json
    def show
	@expense = Expense.find(params[:id])

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @expense }
	end
    end

    # GET /expenses/new
    # GET /expenses/new.json
    def new
	@expense = Expense.new
	# Set amount to nil, we want user to fill something
	@expense.amount=nil

	@pay_methods = PayMethod.order("name").all
	@reasons = Reason.order("name").all
	@stores = Store.order("name").all
	@groups = Group.order('name').all

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @expense }
	end
    end

    # GET /expenses/1/edit
    def edit
	@expense = Expense.find(params[:id])
    end

    # POST /expenses
    # POST /expenses.json
    def create
	@expense = Expense.new(params[:expense])
	# Set user
	@expense.user_id=session[:user_id]

	respond_to do |format|
	    if @expense.save
		format.html { redirect_to "#{expenses_path}/new", notice: 'Expense was successfully created.' }
		format.json { render json: @expense, status: :created, location: @expense }
	    else
		@pay_methods = PayMethod.order("name").all
		@reasons = Reason.order("name").all
		@stores = Store.order("name").all
		@groups = Group.order('name').all
		format.html { render action: "new" }
		format.json { render json: @expense.errors, status: :unprocessable_entity }
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
