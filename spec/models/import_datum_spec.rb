require 'spec_helper'

describe ImportDatum do

    before(:each) do
	@attr={:unique_id => 'abcd', :unique_hash => 'thisisahash', :mapped_fields => {:amount => 10, :date_bought => '2013-02-01'}}
	@attr_ic={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4]}
	@attr_ih={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@new_user_id=1
    end

    def get_valid_import_data(attr=@attr)
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
	# Return object
	return id
    end

    it "should create a new instance given valid attributes" do
	id=get_valid_import_data
	# Try to save
	id.save!
    end

    it "should require a user_id" do
	id=get_valid_import_data()
	# Set field
	id.user_id=nil
	# Test
	id.should_not be_valid
    end
    
    it "should require a valid user_id" do
	id=get_valid_import_data()
	# Set field
	id.user_id=9999
	# Test
	id.should_not be_valid
    end
    
    it "should not require unique_id" do
	id=get_valid_import_data()
	# Set field
	id.unique_id=nil
	# Test
	id.should be_valid
    end

    it "should require unique_hash" do
	id=get_valid_import_data()
	# Set field
	id.unique_hash=nil
	# Test
	id.should_not be_valid
    end
    
    it "should require mapped_fields" do
	id=get_valid_import_data()
	# Set field
	id.mapped_fields=nil
	# Test
	id.should_not be_valid
    end

    it "should require mapped_fields to be a hash" do
	id=get_valid_import_data()
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
	id=get_valid_import_data()
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
	id=get_valid_import_data()
	# Set field
	id.expense_id=1
	# test
	id.should_not be_valid
    end

    it "should require expense_id after processing" do
	id=get_valid_import_data()
	# Save record
	id.save!
	# Set field
	id.expense_id=1
	# test
	id.should be_valid
    end

    it "should not allow the process_flag to be set during creation" do
	id=get_valid_import_data()
	# Set field
	id.process_flag=true
	# test
	id.should_not be_valid
    end

    it "should allow the process_flag to be set after creation" do
	id=get_valid_import_data()
	# Save record
	id.save!
	# Set field
	id.process_flag=true
	# test
	id.should be_valid
    end

    it "should not allow the process_date to be set during creation" do
	id=get_valid_import_data()
	# Set field
	id.process_date=Date.today
	# test
	id.should_not be_valid
    end

    it "should allow the process_date to be set after creation" do
	id=get_valid_import_data()
	# Save record
	id.save!
	# Set field
	id.process_date=Date.today
	# test
	id.should be_valid
    end

    it "should have an import_config method" do
	id=get_valid_import_data()
	id.should respond_to(:import_config)
    end

    it "should have an import_history method" do
	id=get_valid_import_data()
	id.should respond_to(:import_history)
    end

    it "should require an import_history_id" do
	id=get_valid_import_data()
	# Set field
	id.import_history_id=nil
	# Test
	id.should_not be_valid
    end

    it "should require an import_config_id" do
	id=get_valid_import_data()
	# Set field
	id.import_config_id=nil
	# Test
	id.should_not be_valid
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
