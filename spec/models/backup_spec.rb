require 'spec_helper'

describe Backup do
  pending "Please review and verify if more tests are needed: #{__FILE__}"

  before(:each) do
      @attr={:backup_date => Date.today, :backup_dir_size_KB => 100}
  end

  it "should create a new instance given valid attributes" do
      Backup.create!(@attr)
  end

  it "should require a date" do
      missing=Backup.new(@attr.merge(:backup_date => ""))
      missing.should_not be_valid
  end

  it "should have backup_date as a Date" do
      missing=Backup.new(@attr.merge(:backup_date => "abc"))
      missing.should_not be_valid
  end

  it "should require a size" do
      missing=Backup.new(@attr.merge(:backup_dir_size_KB => ""))
      missing.should_not be_valid
  end

  it "should have size as a number" do
      missing=Backup.new(@attr.merge(:backup_dir_size_KB => "abc"))
      missing.should_not be_valid
  end
end
