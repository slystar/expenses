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

    it "should require a unique title" do
	ic=get_valid_import_config
	# Try to save
	ic.save!
	# Create new instance
	ic2=get_valid_import_config
	# Test
	ic2.should_not be_valid
	# Create new instance
	ic3=get_valid_import_config
	# Change title
	ic3.title=ic3.title + 'abc'
	# Test
	ic3.should be_valid
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

    it "should allow unique_id_field to be nil" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.unique_id_field=nil
	# Test
	ic.should be_valid
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
	ic.pay_method_id=nil
	# Test
	ic.should_not be_valid
    end

    it "should allow a nil pre_parser" do
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.pre_parser=nil
	# Test
	ic.should be_valid
    end

    it "should have access to a pre_parser class" do
	# Initial pre-parser class
	lambda { PreParser.new }.should_not raise_error
    end

    it "should reference existing pre-parsers if not nil" do
	# Preparser
	pre_parser='abc'
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.pre_parser=pre_parser
	# Create pre-parser
	pp=PreParser.new
	# Test to make sure this parser does not exist
	pp.should_not respond_to(pre_parser.to_sym)
	# Test to make sure ImportConfig is not valid
	ic.should_not be_valid
    end

    it "should be valid if it references a valid pre_parser" do
	# Preparser
	pre_parser='zzz'
	# Get ImportConfig
	ic=get_valid_import_config()
	# Set field
	ic.pre_parser=pre_parser
	# Add pre_parser for this test
	PreParser.any_instance.stub(pre_parser)
	# Create pre-parser
	pp=PreParser.new
	# Test to make sure this parser does not exist
	pp.should respond_to(pre_parser.to_sym)
	# Test to make sure ImportConfig is not valid
	ic.should be_valid
    end
end
