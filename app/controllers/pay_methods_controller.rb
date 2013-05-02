class PayMethodsController < ApplicationController
    before_filter :login_required

    # GET /pay_methods
    # GET /pay_methods.json
    def index
	@pay_methods = PayMethod.all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @pay_methods }
	end
    end

    # GET /pay_methods/1
    # GET /pay_methods/1.json
    def show
	@pay_method = PayMethod.find(params[:id])

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @pay_method }
	end
    end

    # GET /pay_methods/new
    # GET /pay_methods/new.json
    def new
	@pay_method = PayMethod.new
	@pay_methods = PayMethod.order('name').all

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @pay_method }
	end
    end

    # GET /pay_methods/1/edit
    def edit
	@pay_method = PayMethod.find(params[:id])
    end

    # POST /pay_methods
    # POST /pay_methods.json
    def create
	@pay_method = PayMethod.new(params[:pay_method])

	respond_to do |format|
	    if @pay_method.save
		# Get previous expense
		expense=session[:current_expense]
		# Set new pay method
		if not expense.nil?
		    expense.pay_method_id=@pay_method.id
		    session[:current_expense]=expense
		end
		format.html { redirect_to "#{expenses_path}/new", notice: 'Pay method was successfully created.' }
		format.json { render json: @pay_method, status: :created, location: @pay_method }
	    else
		@pay_methods = PayMethod.order('name').all
		format.html { render action: "new" }
		format.json { render json: @pay_method.errors, status: :unprocessable_entity }
	    end
	end
    end

    # PUT /pay_methods/1
    # PUT /pay_methods/1.json
    def update
	@pay_method = PayMethod.find(params[:id])

	respond_to do |format|
	    if @pay_method.update_attributes(params[:pay_method])
		format.html { redirect_to @pay_method, notice: 'Pay method was successfully updated.' }
		format.json { head :ok }
	    else
		format.html { render action: "edit" }
		format.json { render json: @pay_method.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /pay_methods/1
    # DELETE /pay_methods/1.json
    def destroy
	@pay_method = PayMethod.find(params[:id])
	@pay_method.destroy

	respond_to do |format|
	    format.html { redirect_to pay_methods_url }
	    format.json { head :ok }
	end
    end
end
