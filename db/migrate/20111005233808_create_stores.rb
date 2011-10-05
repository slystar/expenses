class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :store, :null => false

      t.timestamps
    end
  end
end
