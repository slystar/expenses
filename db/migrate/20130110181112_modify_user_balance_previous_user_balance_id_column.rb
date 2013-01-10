class ModifyUserBalancePreviousUserBalanceIdColumn < ActiveRecord::Migration
  def up
      change_column :user_balances, :previous_user_balance_id, :integer, :default => 0
  end

  def down
  end
end
