require 'spec_helper'

describe Backup do

  before(:each) do
      @attr={:backup_date => Date.today, :backup_dir_size_KB => 100}
  end

  it "should create a new instance given valid attributes" do
      Backup.create!(@attr)
  end

  it "should require a date" do
      object=Backup.new(@attr.merge(:backup_date => ""))
      object.should_not be_valid
  end

  it "should have backup_date as a Date" do
      object=Backup.new(@attr.merge(:backup_date => "abc"))
      object.should_not be_valid
  end

  it "should require a size" do
      object=Backup.new(@attr.merge(:backup_dir_size_KB => ""))
      object.should_not be_valid
  end

  it "should not accept characters for the size" do
      object=Backup.new(@attr.merge(:backup_dir_size_KB => "abc"))
      object.should_not be_valid
  end

  it "should accept an integer for the size" do
      object=Backup.new(@attr.merge(:backup_dir_size_KB => "12"))
      object.should be_valid
  end

  it "should floor a float for the size" do
      float=12.5
      object=Backup.new(@attr.merge(:backup_dir_size_KB => float))
      object.backup_dir_size_KB.should equal float.to_i
  end

  it "should have a dump method" do
      # Get backup object
      b=Backup.new()
      # check
      b.should respond_to(:dump)
  end

  it "should be able to dump current data to file" do
      # WARNING: an external backup method should also be used like mysqldump or "sqlite3 DB.sqlite .dump > backup.bak"
      # Backup file
      file='db/data.yml'
      # Get backup object
      b=Backup.create!(@attr)
      # Dump database
      b.dump('development')
      # Check if file exist
      File.exist?(file).should == true
      # Get modification time
      mtime=File.mtime(file)
      # It should have been created in the last 5 seconds
      (Time.now - mtime).should < 5
  end

  pending "should keep a maximum number of backup versions" do
  end

  pending "should have a restore method" do
  end

  pending "should be able to restore file data to database" do
  end
end
