class AddPreviousUserBalanceIdToUserBalance < ActiveRecord::Migration
  def change
    add_column :user_balances, :previous_user_balance_id, :integer
  end
end
