class AddDuplicationCheckToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :duplication_check_hash, :string
    add_column :expenses, :duplication_check_reviewed, :boolean, :default => false
  end
end
