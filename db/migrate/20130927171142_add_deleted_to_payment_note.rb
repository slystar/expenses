class AddDeletedToPaymentNote < ActiveRecord::Migration
  def change
    add_column :payment_notes, :deleted, :boolean, :default => false
  end
end
