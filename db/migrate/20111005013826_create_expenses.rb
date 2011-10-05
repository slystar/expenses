class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.date :date_purchased, :null => false
      t.text :description
      t.integer :pay_method_id, :null => false
      t.integer :reason_id, :null => false
      t.integer :store_id, :null => false
      t.integer :user_id, :null => false
      t.integer :group_id, :null => false
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0.00
      t.date :process_date
      t.boolean :process_flag, :default => false

      t.timestamps
    end
  end
end
