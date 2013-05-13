class AddAppVersion < ActiveRecord::Migration
    def change
	add_column :backups, :app_version, :integer
	add_column :expenses, :app_version, :integer
	add_column :expense_notes, :app_version, :integer
	add_column :group_members, :app_version, :integer
	add_column :groups, :app_version, :integer
	add_column :import_configs, :app_version, :integer
	add_column :import_data, :app_version, :integer
	add_column :import_histories, :app_version, :integer
	add_column :pay_methods, :app_version, :integer
	add_column :payment_notes, :app_version, :integer
	add_column :reasons, :app_version, :integer
	add_column :roles, :app_version, :integer
	add_column :stores, :app_version, :integer
	add_column :update_balance_histories, :app_version, :integer
	add_column :user_balances, :app_version, :integer
	add_column :user_depts, :app_version, :integer
	add_column :user_payments, :app_version, :integer
	add_column :users, :app_version, :integer
	add_column :user_roles, :app_version, :integer
    end
end
