class CreatePaymentNotes < ActiveRecord::Migration
  def change
    create_table :payment_notes do |t|
      t.integer :user_payment_id
      t.integer :user_id
      t.text :note

      t.timestamps
    end
  end
end
