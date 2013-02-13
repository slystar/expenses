require 'spec_helper'

describe ImportConfig do

    before(:each) do
	@attr={:title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [:date_bought,:store_id,:amount]}
	@new_user_id=2
    end

    it "should create a new instance given valid attributes" do
	ic=get_valid_import_config
	# Try to save
	ic.save!
    end

    it "should require a valid user" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.user_id=nil
	# Test
	ic.should_not be_valid
    end

    it "should require a title" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.title=nil
	# Test
	ic.should_not be_valid
    end

    it "should require a description" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.description=nil
	# Test
	ic.should_not be_valid
    end

    it "should require a field_mapping" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.field_mapping=nil
	# Test
	ic.should_not be_valid
    end

    it "should require a hash as field_mapping" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.field_mapping=[1,2]
	# Test
	ic.should_not be_valid
	# Set field
	ic.field_mapping="aaa"
	# Test
	ic.should_not be_valid
	# Set field
	ic.field_mapping=@attr[:field_mapping]
	# Test
	ic.should be_valid
    end

    it "should require a file_type" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.file_type=nil
	# Test
	ic.should_not be_valid
    end

    it "should require approved file types" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.file_type='doc'
	# Test
	ic.should_not be_valid
	# Set field
	ic.file_type='csv'
	# Test
	ic.should be_valid
    end

    it "should require a unique_id_field" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.unique_id_field=nil
	# Test
	ic.should_not be_valid
    end

    it "should require unique_id_hash_fields" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.unique_id_hash_fields=nil
	# Test
	ic.should_not be_valid
    end

    it "should require an array for unique_id_hash_fields" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.unique_id_hash_fields={'a' => 2}
	# Test
	ic.should_not be_valid
	# Set field
	ic.unique_id_hash_fields="aa"
	# Test
	ic.should_not be_valid
	# Set field
	ic.unique_id_hash_fields=[1,2]
	# Test
	ic.should be_valid
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
