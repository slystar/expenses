class ImportDataController < ApplicationController
  # GET /import_data
  # GET /import_data.json
  def index
    @import_data = ImportDatum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_data }
    end
  end

  # GET /import_data/1
  # GET /import_data/1.json
  def show
    @import_datum = ImportDatum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import_datum }
    end
  end

  # GET /import_data/new
  # GET /import_data/new.json
  def new
    @import_datum = ImportDatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @import_datum }
    end
  end

  # GET /import_data/1/edit
  def edit
    @import_datum = ImportDatum.find(params[:id])
  end

  # POST /import_data
  # POST /import_data.json
  def create
    @import_datum = ImportDatum.new(params[:import_datum])

    respond_to do |format|
      if @import_datum.save
        format.html { redirect_to @import_datum, notice: 'Import datum was successfully created.' }
        format.json { render json: @import_datum, status: :created, location: @import_datum }
      else
        format.html { render action: "new" }
        format.json { render json: @import_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /import_data/1
  # PUT /import_data/1.json
  def update
    @import_datum = ImportDatum.find(params[:id])

    respond_to do |format|
      if @import_datum.update_attributes(params[:import_datum])
        format.html { redirect_to @import_datum, notice: 'Import datum was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_data/1
  # DELETE /import_data/1.json
  def destroy
    @import_datum = ImportDatum.find(params[:id])
    @import_datum.destroy

    respond_to do |format|
      format.html { redirect_to import_data_url }
      format.json { head :ok }
    end
  end
end
