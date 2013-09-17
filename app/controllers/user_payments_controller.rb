class UserPaymentsController < ApplicationController
  # GET /user_payments
  # GET /user_payments.json
  def index
    @user_payments = UserPayment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_payments }
    end
  end

  # GET /user_payments/1
  # GET /user_payments/1.json
  def show
    @user_payment = UserPayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_payment }
    end
  end

  # GET /user_payments/new
  # GET /user_payments/new.json
  def new
    @user_payment = UserPayment.new
    @users=User.where("id <> ?",current_user.id)
    @payment_note=PaymentNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_payment }
    end
  end

  # GET /user_payments/1/edit
  def edit
    @user_payment = UserPayment.find(params[:id])
  end

  # POST /user_payments
  # POST /user_payments.json
  def create
    @user_payment = UserPayment.new(params[:user_payment])

    respond_to do |format|
      if @user_payment.save
        format.html { redirect_to @user_payment, notice: 'User payment was successfully created.' }
        format.json { render json: @user_payment, status: :created, location: @user_payment }
      else
        format.html { render action: "new" }
        format.json { render json: @user_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_payments/1
  # PUT /user_payments/1.json
  def update
    @user_payment = UserPayment.find(params[:id])

    respond_to do |format|
      if @user_payment.update_attributes(params[:user_payment])
        format.html { redirect_to @user_payment, notice: 'User payment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_payments/1
  # DELETE /user_payments/1.json
  def destroy
    @user_payment = UserPayment.find(params[:id])
    @user_payment.destroy

    respond_to do |format|
      format.html { redirect_to user_payments_url }
      format.json { head :ok }
    end
  end
end
