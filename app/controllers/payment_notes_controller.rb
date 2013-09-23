class PaymentNotesController < ApplicationController
  def create
    @payment_note = PaymentNote.new(params[:payment_note])
    @user_payment = UserPayment.find(params[:user_payment_id])

    # Set PaymentNote options
    @payment_note.user_payment_id=@user_payment.id
    @payment_note.user_id=current_user.id

    @debug_info=[params,@payment_note.to_yaml]

    respond_to do |format|
      if @payment_note.save
        format.html { redirect_to "/user_payments/#{@user_payment.id}", notice: 'Note successfully created.' }
      else
        format.html { redirect_to "/user_payments/#{@user_payment.id}", alert: "Error: Note could not be created, #{@payment_note.errors.messages}" }
      end
    end
  end
end
