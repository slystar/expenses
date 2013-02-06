require 'spec_helper'

describe ImportHistory do

    before(:each) do
	@attr={:user_id => 1, :import_config_id => 1, :original_file_name = "uploaded_file.csv"}
    end

    it "should create a new instance given valid attributes" do
	ImportHistory.create!(@attr)
    end

    it "should require a user_id" do
	ih=ImportHistory.new(@attr.merge(:user_id => nil ))
	ih.should_not be_valid
    end
    
    pending "should require an import_config" do
    end

    pending "should require a valid import_config_id" do
    end

    pending "should require the original file name" do
    end

    pending "should generate a new file name" do
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
