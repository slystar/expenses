class AddReturnIdToUserPayment < ActiveRecord::Migration
  def change
    add_column :user_payments, :return_id, :integer, :default => 0
  end
end
