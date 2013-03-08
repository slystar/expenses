class AddIndexForUnique < ActiveRecord::Migration
  def change
      add_index :import_data, :unique_id
      add_index :import_data, :unique_hash
      add_index :pay_methods, :name
      add_index :reasons, :name
      add_index :roles, :name
      add_index :stores, :name
  end
end
