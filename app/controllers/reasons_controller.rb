class ReasonsController < ApplicationController
    before_filter :login_required
    # GET /reasons
    # GET /reasons.json
    def index
	@reasons = Reason.all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @reasons }
	end
    end

    # GET /reasons/1
    # GET /reasons/1.json
    def show
	@reason = Reason.find(params[:id])

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @reason }
	end
    end

    # GET /reasons/new
    # GET /reasons/new.json
    def new
	@reason = Reason.new
	@reasons = Reason.order('name').all

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @reason }
	end
    end

    # GET /reasons/1/edit
    def edit
	@reason = Reason.find(params[:id])
    end

    # POST /reasons
    # POST /reasons.json
    def create
	@reason = Reason.new(params[:reason])

	respond_to do |format|
	    if @reason.save
		# Get previous expense
		expense=session[:current_expense]
		# Set new reason
		if not expense.nil?
		    expense.reason_id=@reason.id
		    session[:current_expense]=expense
		end
		format.html { redirect_to "#{expenses_path}/new", notice: 'Reason was successfully created.' }
		format.json { render json: @reason, status: :created, location: @reason }
	    else
		@reasons = Reason.order('name').all
		format.html { render action: "new" }
		format.json { render json: @reason.errors, status: :unprocessable_entity }
	    end
	end
    end

    # PUT /reasons/1
    # PUT /reasons/1.json
    def update
	@reason = Reason.find(params[:id])

	respond_to do |format|
	    if @reason.update_attributes(params[:reason])
		format.html { redirect_to @reason, notice: 'Reason was successfully updated.' }
		format.json { head :ok }
	    else
		format.html { render action: "edit" }
		format.json { render json: @reason.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /reasons/1
    # DELETE /reasons/1.json
    def destroy
	@reason = Reason.find(params[:id])
	@reason.destroy

	respond_to do |format|
	    format.html { redirect_to reasons_url }
	    format.json { head :ok }
	end
    end
end
