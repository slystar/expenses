class AddUpdateBalanceHistoryIdToReturn < ActiveRecord::Migration
  def change
    add_column :returns, :update_balance_history_id, :integer
  end
end
