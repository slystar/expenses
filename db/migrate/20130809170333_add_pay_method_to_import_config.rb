class AddPayMethodToImportConfig < ActiveRecord::Migration
  def change
    add_column :import_configs, :pay_method_id, :integer
  end
end
