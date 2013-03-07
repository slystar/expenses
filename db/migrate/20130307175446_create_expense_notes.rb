class CreateExpenseNotes < ActiveRecord::Migration
  def change
    create_table :expense_notes do |t|
      t.text :note
      t.integer :version

      t.timestamps
    end
  end
end
