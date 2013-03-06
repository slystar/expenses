class AddToExpense < ActiveRecord::Migration
    def change
	add_column :expenses, :duplication_check_reviewed_date, :datetime
	add_column :expenses, :duplication_check_processed, :boolean, :default => false
    end
end
