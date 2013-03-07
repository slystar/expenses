class AddDefaultToExpenseNote < ActiveRecord::Migration
  def change
      change_column :expense_notes, :version, :integer, :default => 0
  end
end
