class FixTransactionDate < ActiveRecord::Migration
  def up
      rename_column :returns, :tranaction_date, :transaction_date
  end

  def down
  end
end
