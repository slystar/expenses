require 'spec_helper'

describe ImportDatum do

    before(:each) do
	@attr={:unique_id => 'abcd', :unique_hash => 'thisisahash', :mapped_fields => {:amount => 10, :date_purchased => '2013-02-01', :store_id => 1}}
	@attr_ic={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4], :date_type => 0}
	@attr_ih={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@new_user_id=1
	@seed_num=1
    end

    def get_next_valid_import_data_object(attr=@attr)
	# Increase seed num
	@seed_num += 1
	# Get a user
	u1=get_next_user
	# Get an import_config
	ic=get_valid_import_config(@attr_ic)
	# Save ImportConfig
	ic.save!
	# Create ImportHistory
	ih=ImportHistory.new(@attr_ih)
	# Add user id because it should not be mass assignable
	ih.user_id=u1.id
	# Set the ImportConfig attribute
	ih.import_config_id=ic.id
	# Save ImportHistory
	ih.save!
	# Get an ImportData object
	id=ImportDatum.new(@attr)
	# Set history
	id.import_history_id=ih.id
	# Set config
	id.import_config_id=ic.id
	# Set User
	id.user_id=u1.id
	# Set unique attr
	id.unique_id=@seed_num + 1
	id.unique_hash=@seed_num + 1
	# Return object
	return id
    end

    it "should create a new instance given valid attributes" do
	id=get_next_valid_import_data_object
	# Try to save
	id.save!
    end

    it "should have a default app_version" do
	object=get_next_valid_import_data_object
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_next_valid_import_data_object
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a user_id" do
	id=get_next_valid_import_data_object()
	# Set field
	id.user_id=nil
	# Test
	id.should_not be_valid
    end
    
    it "should require a valid user_id" do
	id=get_next_valid_import_data_object()
	# Set field
	id.user_id=9999
	# Test
	id.should_not be_valid
    end
    
    it "should not require unique_id" do
	id=get_next_valid_import_data_object()
	# Set field
	id.unique_id=nil
	# Test
	id.should be_valid
    end

    it "should require unique_hash" do
	id=get_next_valid_import_data_object()
	# Set field
	id.unique_hash=nil
	# Test
	id.should_not be_valid
    end
    
    it "should require mapped_fields" do
	id=get_next_valid_import_data_object()
	# Set field
	id.mapped_fields=nil
	# Test
	id.should_not be_valid
    end

    it "should require mapped_fields to be a hash" do
	id=get_next_valid_import_data_object()
	# Set field
	id.mapped_fields=[1,2,3]
	# Test
	id.should_not be_valid
	# Set field
	id.mapped_fields={'a' => 1}
	# Test
	id.should be_valid
    end

    it "should return mapped_fields as a hash" do
	id=get_next_valid_import_data_object()
	# Set field
	id.mapped_fields={'a' => 1}
	# Save record
	id.save!
	# Get record
	id_1=ImportDatum.find(id.id)
	# Test
	id_1.mapped_fields.is_a?(Hash).should == true
    end

    it "should not allow an expense_id during ceation" do
	id=get_next_valid_import_data_object()
	# Set field
	id.expense_id=1
	# test
	id.should_not be_valid
    end

    it "should require expense_id after processing" do
	id=get_next_valid_import_data_object()
	# Save record
	id.save!
	# Set field
	id.expense_id=1
	# test
	id.should be_valid
    end

    it "should not allow the process_flag to be set during creation" do
	id=get_next_valid_import_data_object()
	# Set field
	id.process_flag=true
	# test
	id.should_not be_valid
    end

    it "should allow the process_flag to be set after creation" do
	id=get_next_valid_import_data_object()
	# Save record
	id.save!
	# Set field
	id.process_flag=true
	# test
	id.should be_valid
    end

    it "should not allow the process_date to be set during creation" do
	id=get_next_valid_import_data_object()
	# Set field
	id.process_date=Date.today
	# test
	id.should_not be_valid
    end

    it "should allow the process_date to be set after creation" do
	id=get_next_valid_import_data_object()
	# Save record
	id.save!
	# Set field
	id.process_date=Date.today
	# test
	id.should be_valid
    end

    it "should have an import_config method" do
	id=get_next_valid_import_data_object()
	id.should respond_to(:import_config)
    end

    it "should have an import_history method" do
	id=get_next_valid_import_data_object()
	id.should respond_to(:import_history)
    end

    it "should require an import_history_id" do
	id=get_next_valid_import_data_object()
	# Set field
	id.import_history_id=nil
	# Test
	id.should_not be_valid
    end

    it "should require an import_config_id" do
	id=get_next_valid_import_data_object()
	# Set field
	id.import_config_id=nil
	# Test
	id.should_not be_valid
    end

    it "should have a unique unique_id" do
	id=get_next_valid_import_data_object()
	# Set fields
	id.unique_id='123456'
	# Test
	id.save!
	# Get new record
	id2=get_next_valid_import_data_object
	# Set same user
	id2.user=id.user
	# Set fields
	id2.unique_id='123456'
	# Should not be valid
	id2.should_not be_valid
    end

    it "should have a unique_hash" do
	id=get_next_valid_import_data_object()
	# Set fields
	id.unique_hash='123456'
	# Test
	id.save!
	# Get new record
	id2=get_next_valid_import_data_object
	# Set same user
	id2.user=id.user
	# Set fields
	id2.unique_hash='123456'
	# Should not be valid
	id2.should_not be_valid
    end

    it "should have process_flag set to false on creation" do
	id=get_next_valid_import_data_object()
	# Test
	id.process_flag.should == false
	# Save record
	id.save!
	# Reload
	id.reload
	# Test
	id.process_flag.should == false
    end

    it "should have an expense relationship" do
	id=get_next_valid_import_data_object()
	# Test
	id.should respond_to(:expense)
    end

    it "should have class method imports_to_process" do
	# Test
	ImportDatum.should respond_to(:imports_to_process)
    end

    it "should have imports_to_process return import records" do
	# Create 2 records
	id1=get_next_valid_import_data_object
	id2=get_next_valid_import_data_object
	# Get users
	u1=id1.user_id
	u2=id2.user_id
	# Set fields
	id2.user_id=u1
	# Try to save
	lambda{
	    id1.save!
	    id2.save!
	}.should change(ImportDatum,:count).by(2)
	# Get list of imports
	imports=ImportDatum.imports_to_process(u1)
	# Test
	imports.size.should == 2
	# Get list for user 2
	imports=ImportDatum.imports_to_process(u2)
	# Test
	imports.size.should == 0
    end

    it "should be able to approve valid imported records" do
	# Variables
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Get import_data
	id1=get_next_valid_import_data_object
	# Get expense attributes
	expense_attr=get_attr_expense
	# Merge current mapped_fields
	expense_attr=expense_attr.merge(id1.mapped_fields)
	# Save record
	id1.save!
	# Reload
	id1.reload
	# Approve record
	id1.approve(expense_attr)
	# Reload
	id1.reload
	# Get fields
	amount=id1.mapped_fields[:amount]
	store_id=id1.mapped_fields[:store_id]
	date_purchased=id1.mapped_fields[:date_purchased]
	# Test
	id1.process_flag.should == true
	id1.process_date.strftime("%Y-%m-%d").should == today
	id1.approved.should == true
	# Get related expense
	expense=id1.expense
	# Test
	expense.amount.should == amount
	expense.store_id.should == store_id
	expense.date_purchased.strftime("%Y-%m-%d").should == date_purchased
    end

    it "should return an error when trying to approve an invalid record" do
	# Variables
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Get import_data
	id1=get_next_valid_import_data_object
	# Get expense attributes
	expense_attr={}
	# Merge current mapped_fields
	expense_attr=expense_attr.merge(id1.mapped_fields)
	# Save record
	id1.save!
	# Reload
	id1.reload
	# Approve record
	result=id1.approve(expense_attr)
	# Test
	result.should == false
	id1.errors.size.should > 0
    end

    it "should be able to refuse imported records" do
	# Variables
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Get import_data
	id1=get_next_valid_import_data_object
	# Save record
	id1.save!
	# Reload
	id1.reload
	# Refuse record
	id1.refuse
	# Reload
	id1.reload
	# Test
	id1.process_flag.should == true
	id1.process_date.strftime("%Y-%m-%d").should == today
	id1.expense_id.should == 0
	id1.approved.should == false
    end
end
