class AddCurrentToUserBalance < ActiveRecord::Migration
  def change
    add_column :user_balances, :current, :boolean, :default => false
  end
end
