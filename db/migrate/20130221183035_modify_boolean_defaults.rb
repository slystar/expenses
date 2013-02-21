class ModifyBooleanDefaults < ActiveRecord::Migration
  def up
      change_column :import_data, :process_flag, :boolean, :default => false
      change_column :user_payments, :approved, :boolean, :default => false
  end

  def down
  end
end
