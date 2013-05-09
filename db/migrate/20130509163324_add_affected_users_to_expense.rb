class AddAffectedUsersToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :affected_users, :string
  end
end
