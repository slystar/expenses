class RemovePreviousUserBalanceIdFromUserBalance < ActiveRecord::Migration
  def change
      remove_column :user_balances, :previous_user_balance_id, :integer
  end
end
