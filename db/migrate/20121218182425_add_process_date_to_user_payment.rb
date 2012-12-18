class AddProcessDateToUserPayment < ActiveRecord::Migration
  def change
    add_column :user_payments, :process_date, :datetime
  end
end
