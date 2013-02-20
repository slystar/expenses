require 'spec_helper'

describe ImportHistory do

    before(:each) do
	@attr={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@attr_ic={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4]}
	@new_user_id=1
    end

    def get_valid_import_history(attr=@attr)
	# Get a user
	u1=get_next_user
	# Get an import_config
	ic=get_valid_import_config(@attr_ic)
	# Save ImportConfig
	ic.save!
	# Create ImportHistory
	ih=ImportHistory.new(attr)
	# Add user id because it should not be mass assignable
	ih.user_id=u1.id
	# Set the ImportConfig attribute
	ih.import_config_id=ic.id
	# Return object
	return ih
    end

    it "should create a new instance given valid attributes" do
	ih=get_valid_import_history
	# Try to save
	ih.save!
    end

    it "should require a user_id" do
	ih=get_valid_import_history()
	# Set field
	ih.user_id=nil
	# Test
	ih.should_not be_valid
    end
    
    it "should require a valid user_id" do
	ih=get_valid_import_history()
	# Set field
	ih.user_id=9999
	# Test
	ih.should_not be_valid
    end
    
    it "should require an import_config_id" do
	ih=get_valid_import_history()
	# Set import_config_id
	ih.import_config_id=nil
	# Test
	ih.should_not be_valid
    end

    it "should require a valid import_config_id" do
	ih=get_valid_import_history()
	# Set field
	ih.import_config_id=99999
	# Test
	ih.should_not be_valid
    end

    it "should require the original file name" do
	ih=get_valid_import_history()
	# Set field
	ih.original_file_name=nil
	# Test
	ih.should_not be_valid
	# Set field
	ih.original_file_name=''
	# Test
	ih.should_not be_valid
    end

    it "should create new file with name YEAR_MONTH_DAY_HASH" do
	# Set target dir
	storage_dir=Dir.tmpdir
	# Filename pattern
	pattern=/\d\d\d\d_\d\d_\d\d_.{40}/
	# Get object
	ih=get_valid_import_history()
	# Set file content
	file_content='This is a test file content'
	# Save file
	ih.save_file(file_content,storage_dir)
	# Save record
	ih.save!
	# Get filename
	filename=ih.new_file_name
	# Test
	filename.should_not be_blank
	# Test
	filename.should =~ pattern
	# Set new file paht
	new_file_path=File.join(storage_dir,filename)
	# New file digest
	new_file_digest=Digest::SHA2.hexdigest(File.read(new_file_path))
	# Get filename digest
	file_name_digest=filename.split('_').last
	# Check file
	new_file_digest.should == file_name_digest
    end

    pending "should require upload with content" do
	# Read tmp file from upload
	# Check data size
    end

    it "should generate an error when importing an unknown filetype" do
	# Get import history
	ih=get_valid_import_history()
	# Get import config
	ic=ih.import_config
	# Set new filetype
	ic.file_type='docx'
	# Import file
	result=ih.import_data('test.docx',ic,ih.user_id)
	# Test
	result.should == false
	# Errors should exist
	ih.errors.size.should > 0
    end

    it "should be able to import csv from amex" do
	# Import config attributes
	@attr_ic={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_bought => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3]}
	# Import file
	filename='spec/imports/amex.csv'
	# Get import history
	ih=get_valid_import_history()
	# Save import_history
	ih.save!
	# Get import config
	ic=ih.import_config
	# Get user
	u=ih.user_id
	# Import data
	ih.import_data(filename,ic,u)
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 3 new rows
	id.size.should == 3
	# Get first record
	id1=id.first
	# Get Date bought
	date_bought=id1.mapped_fields[:date_bought]
	# Check Date
	date_bought.strftime("%Y-%m-%d").should == Date.parse('2012-12-01').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "38.31"
	# Check Store
	id1.mapped_fields[:store].should == "ULTRAMAR"
    end

    it "should be able to import csv from pcfinancial" do
	# Import config attributes
	@attr_ic={:title => 'PC', :description => 'CSV export of PC MC', :field_mapping => {:date_bought => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 7, :unique_id_hash_fields => [0,2,3]}
	# Import file
	filename='spec/imports/pc_financial.csv'
	# Get import history
	ih=get_valid_import_history()
	# Save import_history
	ih.save!
	# Get import config
	ic=ih.import_config
	# Get user
	u=ih.user_id
	# Import data
	ih.import_data(filename,ic,u)
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 2 new rows
	id.size.should == 2
	# Get first record
	id1=id.first
	# Get Date bought
	date_bought=id1.mapped_fields[:date_bought]
	# Check Date
	date_bought.strftime("%Y-%m-%d").should == Date.parse('2013-01-26').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "34.74"
	# Check Store
	id1.mapped_fields[:store].should == "store 1"
    end

    pending "should be able to ignore duplicate entries during import" do
    end
end
