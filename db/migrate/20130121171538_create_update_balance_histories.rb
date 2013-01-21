class CreateUpdateBalanceHistories < ActiveRecord::Migration
  def change
    create_table :update_balance_histories do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
