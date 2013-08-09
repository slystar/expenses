require 'spec_helper'

describe ImportConfig do

    before(:each) do
	@attr={:title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [:date_purchased,:store_id,:amount], :date_type => 0}
	@new_user_id=2
    end

    it "should create a new instance given valid attributes" do
	ic=get_valid_import_config
	# Try to save
	ic.save!
    end

    it "should have a default app_version" do
	object=get_valid_import_config
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_valid_import_config
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
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

    it "should return a hash for field_mapping" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.field_mapping=@attr[:field_mapping]
	# Save record
	ic.save!
	# Retrieve record
	new_ic=ImportConfig.find(ic.id)
	# Test
	new_ic.field_mapping.is_a?(Hash).should == true
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

    it "should return an array for unique_id_hash_fields" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.unique_id_hash_fields=[1,2]
	# Save record
	ic.save!
	# Retrieve record
	new_ic=ImportConfig.find(ic.id)
	# Test
	new_ic.unique_id_hash_fields.is_a?(Array).should == true
    end

    it "should require a DateType" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.date_type=nil
	# Test
	ic.should_not be_valid
    end

    it "should require a valid DateType" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.date_type=999
	# Test
	ic.should_not be_valid
    end

    it "should accept valid DateType" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.date_type=0
	# Test
	ic.should be_valid
    end

    it "should require a PayMethod" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.pay_method=nil
	# Test
	ic.should_not be_valid
    end
end
