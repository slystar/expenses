class CreateReturns < ActiveRecord::Migration
  def change
    create_table :returns do |t|
      t.integer :expense_id
      t.decimal :amount
      t.text :description
      t.integer :user_id
      t.date :tranaction_date

      t.timestamps
    end
  end
end
