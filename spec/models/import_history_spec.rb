require 'spec_helper'

describe ImportHistory do

    before(:each) do
	@attr={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@attr_ic={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4], :date_type => 0}
	@attr_ic_amex={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
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

    def import_amex()
	# Import config attributes
	@attr_ic=@attr_ic_amex
	# Import file
	@filename='spec/imports/amex.csv'
	# Get import history
	ih=get_valid_import_history()
	# Save import_history
	ih.save!
	# Get import config
	ic=ih.import_config
	# Get user
	u=ih.user_id
	# Import data
	ih.import_data(@filename,ic,u)
	# Return ImportHistory
	return ih
    end

    it "should create a new instance given valid attributes" do
	ih=get_valid_import_history
	# Try to save
	ih.save!
    end

    it "should have a default app_version" do
	object=get_valid_import_history
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_valid_import_history
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
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
	# Delete tmp file
	File.delete(File.join(storage_dir,filename))
    end

    it "should require upload with content" do
	# Set target dir
	storage_dir=Dir.tmpdir
	# Simulate empty file
	file_content=''
	# Get object
	ih=get_valid_import_history()
	# Save file
	ih.save_file(file_content,storage_dir).should == nil
	# Save record
	ih.save.should == false
	# Test
	ih.errors.size.should == 1
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
	# Import data
	ih=import_amex
	# Get line count
	file_line_count=File.open(@filename,'r'){|fin| fin.lines.count}
	# Get sizes
	ok_records=ih.import_accepted
	bad_records=ih.import_rejected
	# Test: should have list of imported and rejected rows
	ok_records.size.should > 0
	bad_records.size.should > 0
	(ok_records.size + bad_records.size).should == file_line_count
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 3 new rows
	id.size.should == 3
	# Get first record
	id1=id.first
	# Get Date bought
	date_purchased=id1.mapped_fields[:date_purchased]
	# Check Date
	date_purchased.strftime("%Y-%m-%d").should == Date.parse('2012-12-01').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "38.31"
	# Check Store
	id1.mapped_fields[:store].should == "ULTRAMAR"
    end

    it "should be able to import csv from pcfinancial" do
	# Import config attributes
	@attr_ic={:title => 'PC', :description => 'CSV export of PC MC', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 7, :unique_id_hash_fields => [0,2,3], :date_type => 0}
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
	date_purchased=id1.mapped_fields[:date_purchased]
	# Check Date
	date_purchased.strftime("%Y-%m-%d").should == Date.parse('2013-01-26').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "34.74"
	# Check Store
	id1.mapped_fields[:store].should == "store 1"
    end

    it "should be able to ignore duplicate entries during import" do
	# Import file
	filename='spec/imports/amex.csv'
	# Get Import data
	ih=import_amex
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 3 new rows
	id.size.should == 3
	# Get new import history
	ih2=get_valid_import_history()
	# Save import_history
	ih2.save!
	# Get import config
	ic=ih2.import_config
	# Get user
	u=ih.user_id
	# Test same user
	u.should == ih.user_id
	# Import data
	ih2.import_data(filename,ic,u)
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should still contain 3 new rows
	id.size.should == 3
	# Test: errors should still be zero, because it's not an error
	ih2.errors.size.should == 0
    end

    it "should be able to imort the same record by each user" do
	# Variables
	@new_user_id = 1
	@attr_ic = @attr_ic_amex
	# Import file
	filename='spec/imports/amex.csv'
	# Get new import history
	ih=get_valid_import_history()
	# Set new user
	ih.user=get_next_user
	# Save import_history
	ih.save!
	# Get import config
	ic=ih.import_config
	# Get new user
	u=ih.user_id
	# Import data
	ih.import_data(filename,ic,u)
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 3 new rows
	id.size.should == 3
	# Get new import history
	ih2=get_valid_import_history()
	# Set new user
	ih2.user=get_next_user
	# Save import_history
	ih2.save!
	# Get import config
	ic=ih2.import_config
	# Get new user
	u=ih2.user_id
	# Test: users should be different
	u.should_not == ih.user_id
	# Import data
	ih2.import_data(filename,ic,u)
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should contain 6 new rows
	id.size.should == 6
	# Test: errors should still be zero, because it's not an error
	ih2.errors.size.should == 0
    end

    it "should be able to provide a list or records to be processed" do
	# Get Import data
	ih=import_amex
	# Get user
	user_id=ih.user_id
	# Get all ImportData
	id=ImportDatum.all
	# ImportData should still contain 3 new rows
	id.size.should == 3
	# Get a list of imports to process
	records=ImportDatum.imports_to_process(user_id)
	# Check size
	records.size.should == id.size
    end
end
