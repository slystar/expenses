class StoresController < ApplicationController
    before_filter :login_required
    # GET /stores
    # GET /stores.json
    def index
	@stores = Store.all

	respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @stores }
	end
    end

    # GET /stores/1
    # GET /stores/1.json
    def show
	@store = Store.find(params[:id])

	respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: @store }
	end
    end

    # GET /stores/new
    # GET /stores/new.json
    def new
	@store = Store.new
	@stores = Store.order('name').all

	respond_to do |format|
	    format.html # new.html.erb
	    format.json { render json: @store }
	end
    end

    # GET /stores/1/edit
    def edit
	@store = Store.find(params[:id])
    end

    # POST /stores
    # POST /stores.json
    def create
	@store = Store.new(params[:store])

	respond_to do |format|
	    if @store.save
		# Get previous expense
		expense=session[:current_expense]
		# Set new store
		if not expense.nil?
		    expense.store_id=@store.id
		    session[:current_expense]=expense
		end
		format.html { redirect_to "#{expenses_path}/new", notice: 'Store was successfully created.' }
		format.json { render json: @store, status: :created, location: @store }
	    else
		@stores = Store.order('name').all
		format.html { render action: "new" }
		format.json { render json: @store.errors, status: :unprocessable_entity }
	    end
	end
    end

    # PUT /stores/1
    # PUT /stores/1.json
    def update
	@store = Store.find(params[:id])

	respond_to do |format|
	    if @store.update_attributes(params[:store])
		format.html { redirect_to @store, notice: 'Store was successfully updated.' }
		format.json { head :ok }
	    else
		format.html { render action: "edit" }
		format.json { render json: @store.errors, status: :unprocessable_entity }
	    end
	end
    end

    # DELETE /stores/1
    # DELETE /stores/1.json
    def destroy
	@store = Store.find(params[:id])
	@store.destroy

	respond_to do |format|
	    format.html { redirect_to stores_url }
	    format.json { head :ok }
	end
    end

    # Parents selectino
    def parents
	@stores = Store.order(:name).all
    end

    # Parents save
    def save_parents
	# Variables
	processed_ids=[]
	# Get stores with parents
	stores_with_parents=Store.select("id, parent_id").where("parent_id > ?",0)
	# Collect store ids for stores with parents
	stores_with_parents_ids=stores_with_parents.collect{|s| s.id.to_i}
	# Create hash for stores with parents
	existing_stores_with_parents={}
	stores_with_parents.each{|s| existing_stores_with_parents[s.id]=s.parent_id}
	# Get parents
	parents_all=params[:parents]
	# Keep parents with IDs
	@parents=parents_all.reject{|k,v| v.empty?}
	# Set new parents
	@parents.each do |name,id|
	    # Extract source store
	    source_store_id=name.gsub(/.*_/,'').to_i
	    parent_id=id.to_i
	    make_change=true
	    # check if this store had a previous parent
	    if existing_stores_with_parents[source_store_id]
		# check if there was a change
		if existing_stores_with_parents[source_store_id].to_i == parent_id
		    # Make change
		    make_change=false
		end
	    end
	    # Check if we need to make update
	    if make_change
		# Find the source store
		store=Store.find(source_store_id)
		# Update it
		store.parent_id=id
		# Save
		store.save
	    end
	    # Track ids
	    processed_ids.push(source_store_id)
	end
	# Remove parents
	(stores_with_parents_ids - processed_ids).each do |id|
	    # Find store
	    store=Store.find(id)
	    # clear the parent from this store
	    store.parent_id=0
	    # Save
	    store.save
	end
	# Redirect
	respond_to do |format|
	    format.html { redirect_to "#{stores_url}/parents", notice: "Parents updated" }
	end
    end
end
