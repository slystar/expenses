class RenameColumns < ActiveRecord::Migration
    def change
	rename_column :stores, :store, :name
	rename_column :pay_methods, :pay_method, :name
	rename_column :reasons, :reason, :name
    end
end
