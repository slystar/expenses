class CreateImportData < ActiveRecord::Migration
  def change
    create_table :import_data do |t|
      t.integer :user_id
      t.integer :import_history_id
      t.integer :import_config_id
      t.string :unique_id
      t.string :unique_hash
      t.text :mapped_fields
      t.boolean :process_flag
      t.datetime :process_date
      t.integer :expense_id
      t.text :process_notes

      t.timestamps
    end
  end
end
