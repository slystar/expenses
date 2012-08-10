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
end
