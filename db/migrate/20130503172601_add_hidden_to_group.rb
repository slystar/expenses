class AddHiddenToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :hidden, :boolean, :default => false
  end
end
