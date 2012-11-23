class CreateUserDepts < ActiveRecord::Migration
  def change
    create_table :user_depts do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.decimal :amount

      t.timestamps
    end
  end
end
