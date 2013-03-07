class RenameNoteIdToExpenseNoteIdInExpense < ActiveRecord::Migration
  def up
      rename_column :expenses, :note_id, :expense_note_id
  end

  def down
      rename_column :expenses, :expense_note_id, :note_id
  end
end
