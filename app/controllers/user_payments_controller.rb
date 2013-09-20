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
      # Get objects
    @user_payment = UserPayment.new
    @users=User.where("id <> ?",current_user.id).all

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
    @payment_note = PaymentNote.new(params[:payment_note])
    @users=User.where("id <> ?",current_user.id).all

    # Set defaults
    @user_payment.from_user_id=current_user.id

    respond_to do |format|
      if @user_payment.save
	  # Check if there is a note to save
	  if @payment_note.note.size > 0
	      # Reload
	      @user_payment.reload
	      # Set PaymentNote options
	      @payment_note.user_payment_id=@user_payment.id
	      @payment_note.user_id=current_user.id
	      # Save note
	      @payment_note.save!
	  end
        format.html { redirect_to menu_path, notice: 'User payment was successfully created.' }
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
