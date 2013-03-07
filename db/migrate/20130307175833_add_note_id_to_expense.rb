class AddNoteIdToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :note_id, :integer
  end
end
