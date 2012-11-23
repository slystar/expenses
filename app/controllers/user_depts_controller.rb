class UserDeptsController < ApplicationController
  # GET /user_depts
  # GET /user_depts.json
  def index
    @user_depts = UserDept.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_depts }
    end
  end

  # GET /user_depts/1
  # GET /user_depts/1.json
  def show
    @user_dept = UserDept.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_dept }
    end
  end

  # GET /user_depts/new
  # GET /user_depts/new.json
  def new
    @user_dept = UserDept.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_dept }
    end
  end

  # GET /user_depts/1/edit
  def edit
    @user_dept = UserDept.find(params[:id])
  end

  # POST /user_depts
  # POST /user_depts.json
  def create
    @user_dept = UserDept.new(params[:user_dept])

    respond_to do |format|
      if @user_dept.save
        format.html { redirect_to @user_dept, notice: 'User dept was successfully created.' }
        format.json { render json: @user_dept, status: :created, location: @user_dept }
      else
        format.html { render action: "new" }
        format.json { render json: @user_dept.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_depts/1
  # PUT /user_depts/1.json
  def update
    @user_dept = UserDept.find(params[:id])

    respond_to do |format|
      if @user_dept.update_attributes(params[:user_dept])
        format.html { redirect_to @user_dept, notice: 'User dept was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_dept.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_depts/1
  # DELETE /user_depts/1.json
  def destroy
    @user_dept = UserDept.find(params[:id])
    @user_dept.destroy

    respond_to do |format|
      format.html { redirect_to user_depts_url }
      format.json { head :ok }
    end
  end
end
