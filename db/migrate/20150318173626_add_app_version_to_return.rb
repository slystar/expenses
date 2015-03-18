class AddAppVersionToReturn < ActiveRecord::Migration
  def change
      add_column    :returns, :app_version, :integer
  end
end
