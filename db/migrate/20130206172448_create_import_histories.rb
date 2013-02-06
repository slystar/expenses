class CreateImportHistories < ActiveRecord::Migration
  def change
    create_table :import_histories do |t|
      t.integer :user_id
      t.integer :import_config_id
      t.string :original_file_name
      t.string :new_file_name

      t.timestamps
    end
  end
end
