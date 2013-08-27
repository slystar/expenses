class AddReverseBalanceIdToUserBalance < ActiveRecord::Migration
  def change
    add_column :user_balances, :reverse_balance_id, :integer, :default => 0
  end
end
