class AddProcessToReturn < ActiveRecord::Migration
  def change
      add_column    :returns, :process_flag, :boolean, :default => :false
      add_column    :returns, :process_date, :date
  end
end
