class AddProcessDateToUserDept < ActiveRecord::Migration
  def change
    add_column :user_depts, :process_date, :datetime
  end
end
