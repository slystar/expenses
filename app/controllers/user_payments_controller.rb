class UserPaymentsController < ApplicationController
    before_filter :login_required

  # GET /user_payments
  # GET /user_payments.json
  def index
    @user_payments = UserPayment.includes(:from_user).includes(:to_user).where("from_user_id = ? or to_user_id = ?",current_user.id,current_user.id).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_payments }
    end
  end

  # GET /user_payments/1
  # GET /user_payments/1.json
  def show
    @user_payment = UserPayment.includes(:from_user).includes(:to_user).includes(:payment_notes).find(params[:id])
    @payment_note = PaymentNote.new

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
    @users=User.where("id <> ?",current_user.id).where(:hidden => false).all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_payment }
    end
  end

  # GET /user_payments/1/edit
  def edit
    @user_payment = UserPayment.find(params[:id])
    @users=User.where("id <> ?",current_user.id).where(:hidden => false).all
  end

  # POST /user_payments
  # POST /user_payments.json
  def create
    @user_payment = UserPayment.new(params[:user_payment])
    @payment_note = PaymentNote.new(params[:payment_note])
    @users=User.where("id <> ?",current_user.id).where(:hidden => false).all

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

  # Add note
  def add_note
    @payment_note = PaymentNote.new(params[:payment_note])
    @user_payment = UserPayment.find(params[:user_payment_id])

    # Set PaymentNote options
    @payment_note.user_payment_id=@user_payment.id
    @payment_note.user_id=current_user.id

    respond_to do |format|
      if @payment_note.save
        format.html { redirect_to "/user_payments/#{@user_payment.id}", notice: 'Note successfully created.' }
      else
        format.html { render action: "show" }
      end
    end
  end

  # Remove note
  def remove_note
    @payment_note = PaymentNote.find(params[:id])
    @user_payment = @payment_note.user_payment

    respond_to do |format|
	if @payment_note.delete_note
	  format.html { redirect_to "/user_payments/#{@user_payment.id}", notice: 'Note successfully deleted' }
	  format.json { head :ok }
	else
	  format.html { redirect_to "/user_payments/#{@user_payment.id}", alert: "#{@payment_note.errors.messages.values.join(',')}" }
	end
    end
  end

  # Approve user payments
  def approve
      # Get records that need approval
      @user_payments=current_user.get_user_payments_waiting_for_approval
      # Go back to menu if none exist
      if @user_payments.size < 1
	  redirect_to menu_path and return
      end
  end

  # Method to approve payment
  def approve_payment
      # Get records that need approval
      user_payments=current_user.get_user_payments_waiting_for_approval
      # Get user_payment
      user_payment=UserPayment.find(params[:user_payment_id])
      # Get note
      note=params[:payment_approval][:note]
      # Get submit value
      submit=params[:commit]
      # Try to create note
      payment_note=PaymentNote.new(:note => note)
      payment_note.user_id=current_user.id
      payment_note.user_payment_id=user_payment.id
      # Check submit button
      if submit =~ /approve/i
	  # Aprove
	  if user_payment.approve(current_user.id)
	      redirect_to menu_path, notice: "Payment approved"
	  else
	      redirect_to "/user_payments/approve", alert: "Error: could not approve UserPayment id:#{user_payment.id}, #{user_payment.errors.full_messages}" and return
	  end
      elsif submit =~ /reject/i
	  # Check for note
	  if not payment_note.valid?
	      # Note required
	      redirect_to "/user_payments/approve", alert: "Error: could not reject UserPayment because a Note is required. Message: #{payment_note.errors.full_messages}" and return
	  end
	  # Bounce message back
	  user_payment.waiting_on_user_id=user_payment.from_user_id
	  # Save record
	  if user_payment.save
	      # Save note
	      payment_note.save!
	  end
	  # Notice
	  notice="Payment successfully rejected."
	  # Check if more user_payments
	  if user_payments.size > 0
	      # Redirect to approve
	      redirect_to "/user_payments/approve", notice: notice and return
	  else
	      # Redirect to menu
	      redirect_to menu_path, notice: notice and return
	  end
      else
	  # Check for note
	  if not payment_note.valid?
	      # Note required
	      redirect_to "/user_payments/approve", alert: "Error: could not re-submit UserPayment because a Note is required. Message: #{payment_note.errors.full_messages}" and return
	  end
	  # Bounce message back
	  user_payment.waiting_on_user_id=user_payment.to_user_id
	  # Save record
	  if user_payment.save
	      # Save note
	      payment_note.save!
	  end
	  # Notice
	  notice="Payment successfully re-submitted."
	  # Check if more user_payments
	  if user_payments.size > 0
	      # Redirect to approve
	      redirect_to "/user_payments/approve", notice: notice and return
	  else
	      # Redirect to menu
	      redirect_to menu_path, notice: notice and return
	  end
      end
  end
end
