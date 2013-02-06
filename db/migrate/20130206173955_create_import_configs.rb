class CreateImportConfigs < ActiveRecord::Migration
  def change
    create_table :import_configs do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.text :field_mapping
      t.string :file_type
      t.string :unique_id_field
      t.text :unique_id_hash_fields

      t.timestamps
    end
  end
end
