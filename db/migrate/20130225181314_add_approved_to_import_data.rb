class AddApprovedToImportData < ActiveRecord::Migration
  def change
    add_column :import_data, :approved, :boolean, :default => nil
  end
end
