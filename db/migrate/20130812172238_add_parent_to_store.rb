class AddParentToStore < ActiveRecord::Migration
  def change
    add_column :stores, :parent_id, :integer, :default => 0
  end
end
