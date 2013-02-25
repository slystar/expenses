class AddDateTypeToImportConfig < ActiveRecord::Migration
  def change
    add_column :import_configs, :date_type, :integer
  end
end
