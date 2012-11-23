class CreateUserPayments < ActiveRecord::Migration
  def change
    create_table :user_payments do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.decimal :amount
      t.boolean :approved
      t.datetime :approved_date

      t.timestamps
    end
  end
end
