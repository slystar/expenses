class AddUpdateBalanceHistory < ActiveRecord::Migration
  def change
    add_column :user_payments, :update_balance_history_id, :integer
    add_column :user_depts, :update_balance_history_id, :integer
    add_column :user_balances, :update_balance_history_id, :integer
  end
end
