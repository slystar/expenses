class CreateBackups < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.datetime :backup_date
      t.integer :backup_dir_size_KB

      t.timestamps
    end
  end
end
