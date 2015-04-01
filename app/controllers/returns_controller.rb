class ReturnsController < ApplicationController
    before_filter :login_required

  # GET /returns
  # GET /returns.json
  def index
    @returns = Return.all

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
    @return = Return.new

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

    respond_to do |format|
      if @return.save
        format.html { redirect_to @return, notice: 'Return was successfully created.' }
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
    @return = Return.find(params[:id])
    @return.destroy

    respond_to do |format|
      format.html { redirect_to returns_url }
      format.json { head :no_content }
    end
  end
end
