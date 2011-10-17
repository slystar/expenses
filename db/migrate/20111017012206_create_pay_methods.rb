class CreatePayMethods < ActiveRecord::Migration
  def change
    create_table :pay_methods do |t|
      t.string :pay_method

      t.timestamps
    end
  end
end
