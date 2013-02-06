require 'spec_helper'

describe ImportHistory do

    before(:each) do
	@attr={:user_id => 1, :import_config_id => 1, :original_file_name => "uploaded_file.csv"}
    end

    def get_valid_import_history(attr=@attr)
	ih=ImportHistory.new(attr)
	# Add user id because it should not be mass assignable
	ih.user_id=attr[:user_id]
	# Add new_file_name
	ih.new_file_name=ImportHistory.generate_new_file_name(ih.original_file_name)
	# Return object
	return ih
    end

    it "should create a new instance given valid attributes" do
	ih=get_valid_import_history
	# Try to save
	ih.save!
    end

    it "should require a user_id" do
	ih=get_valid_import_history(@attr.merge(:user_id => nil ))
	ih.should_not be_valid
    end
    
    it "should require an import_config_id" do
	ih=get_valid_import_history(@attr.merge(:import_config_id => nil ))
	ih.should_not be_valid
    end

    it "should require a valid import_config_id" do
	ih=get_valid_import_history(@attr.merge(:import_config_id => 99999 ))
	ih.should_not be_valid
    end

    pending "should require the original file name" do
    end

    pending "should generate a new file name" do
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
