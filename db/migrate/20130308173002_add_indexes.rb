class AddIndexes < ActiveRecord::Migration
  def up
      add_index :group_members, :user_id
      add_index :group_members, :group_id
      add_index :import_configs, :user_id
      add_index :import_data, :user_id
      add_index :import_histories, :user_id
      add_index :update_balance_histories, :user_id
      add_index :user_balances, :from_user_id
      add_index :user_balances, :to_user_id
      add_index :user_depts, :from_user_id
      add_index :user_depts, :to_user_id
      add_index :user_payments, :from_user_id
      add_index :user_payments, :to_user_id
      add_index :user_roles, :user_id
      add_index :user_roles, :role_id
      add_index :users, :user_name
  end

  def down
  end
end
