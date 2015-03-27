class RenameColumnInReturn < ActiveRecord::Migration
    def change
	rename_column :returns, :update_balance_history_id, :user_payment_id
    end
end
