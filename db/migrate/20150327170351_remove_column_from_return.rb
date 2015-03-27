class RemoveColumnFromReturn < ActiveRecord::Migration
  def change
      remove_column :returns, :user_payment_id
  end
end
