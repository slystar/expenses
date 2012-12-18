class AddProcessFlagToUserPayment < ActiveRecord::Migration
  def change
    add_column :user_payments, :process_flag, :boolean, :default => false
  end
end
