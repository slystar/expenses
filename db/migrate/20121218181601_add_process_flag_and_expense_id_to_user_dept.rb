class AddProcessFlagAndExpenseIdToUserDept < ActiveRecord::Migration
  def change
    add_column :user_depts, :process_flag, :boolean, :default => false
    add_column :user_depts, :expense_id, :integer
  end
end
