class ReturnsController < ApplicationController
    before_filter :login_required

    # GET /returns
    # GET /returns.json
    def index
	@returns = Return.includes(:user).all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @returns }
	end
    end

    # GET /returns/1
    # GET /returns/1.json
    def show
	@return = Return.find(params[:id])

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @return }
	end
    end

    # GET /returns/new
    # GET /returns/new.json
    def new
	# Get new return
	@return = Return.new
	# Check params
	expense_id=params[:expense_id]
	# Check if return is valid
	# Set expense id if available
	if not expense_id.nil?
	    # Get expense
	    expense=Expense.find_by_id(expense_id)
	    # Check if expense is valid
	    if expense
		# Set attributes
		@expense=expense
		@return.expense_id=expense_id
		@return.transaction_date=expense.date_purchased
	    end
	end

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @return }
	end
    end

    # GET /returns/1/edit
    def edit
	@return = Return.find(params[:id])
    end

    # POST /returns
    # POST /returns.json
    def create
	@return = Return.new(params[:return])
	# Set user
	@return.user_id=session[:user_id]
	# check for existing expense
	if @return.expense
	    # Set variable
	    @expense=@return.expense
	else
	    @return.expense_id=nil
	end

	respond_to do |format|
	    if @return.save
		# Get path
		if session[:return_to]
		    path=session.delete(:return_to)
		else
		    path="#{returns_path}/new"
		end
		format.html { redirect_to path, notice: 'Return was successfully created.' }
		format.json { render json: @return, status: :created, location: @return }
	    else
		format.html { render action: "new" }
		format.json { render json: @return.errors, status: :unprocessable_entity }
	    end
	end
    end

    # PUT /returns/1
    # PUT /returns/1.json
    def update
	@return = Return.find(params[:id])

	respond_to do |format|
	    if @return.update_attributes(params[:return])
		format.html { redirect_to @return, notice: 'Return was successfully updated.' }
		format.json { head :no_content }
	    else
		format.html { render action: "edit" }
		format.json { render json: @return.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /returns/1
    # DELETE /returns/1.json
    def destroy
	# Get return
	@return = Return.find(params[:id])

	respond_to do |format|
	    if @return.destroy
		format.html { redirect_to returns_url, notice: "Return successfully destroyed" }
		format.json { head :no_content }
	    else
		format.html { redirect_to returns_url, alert: "Error: #{@return.errors.messages[:base].first}" }
		format.json { head :no_content }
	    end
	end
    end
end
