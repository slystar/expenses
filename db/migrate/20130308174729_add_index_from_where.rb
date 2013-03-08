class AddIndexFromWhere < ActiveRecord::Migration
  def change
      add_index :expenses, :duplication_check_hash
      add_index :expenses, :duplication_check_processed
      add_index :expenses, :user_id
      add_index :import_data, [:user_id, :process_flag]
      add_index :user_depts, :process_flag
      add_index :user_payments, [:process_flag, :approved]
      add_index :user_balances, :current
      add_index :user_balances, :amount
      add_index :groups, :name
  end
end
