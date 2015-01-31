class AddWaitingOnUserIdToUserPayment < ActiveRecord::Migration
  def change
    add_column :user_payments, :waiting_on_user_id, :integer
  end
end
