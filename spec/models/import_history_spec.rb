require 'spec_helper'
require 'fileutils'

describe ImportHistory do

    before(:each) do
	@attr={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@attr_ic={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4], :date_type => 0}
	@attr_ic_pc={:title => 'PC', :description => 'CSV export of PC MC', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 7, :unique_id_hash_fields => [0,2,3], :date_type => 0}
	@attr_ic_amex={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
	@attr_ic_capital_one_mc={:title => 'CapitalOne MC', :description => 'CSV export of CapitalOne MC', :field_mapping => {:date_purchased => 1, :amount => 3, :store => 2}, :file_type => 'csv', :unique_id_field => 0, :unique_id_hash_fields => [1,2,3], :date_type => 0, :pre_parser => 'p_mc_capital_one'}
	@new_user_id=1
    end

    def import_amex(user_id=nil)
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
	# Check user
	if user_id
	    # Set user
	    u=user_id
	else
	    # Get user
	    u=ih.user_id
	end
	# Import data
	ih.import_data(@filename,ic,u)
	# Remove any saved files
	ih.remove_saved_file.should == true
	# Return ImportHistory
	return ih
    end

    def import_pc(user_id=nil)
	# Import config attributes
	@attr_ic=@attr_ic_pc
	# Import file
	@filename='spec/imports/pc_financial.csv'
	# Get import history
	ih=get_valid_import_history()
	# Save import_history
	ih.save!
	# Get import config
	ic=ih.import_config
	# Check user
	if user_id
	    # Set user
	    u=user_id
	else
	    # Get user
	    u=ih.user_id
	end
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
	# Save record
	ih.save!
	# Set file content
	file_content='This is a test file content'
	# Save file
	ih.save_file(file_content,storage_dir)
	# Get filename
	filename=ih.new_file_name
	# Test
	filename.should_not be_blank
	ImportHistory.last.new_file_name.should == filename
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
	# Get temp file name
	temp_file=File.join(Dir.tmpdir,'tmp.docx')
	# Check if file exists
	if not File.exist?(temp_file)
	    # Create temp file
	    FileUtils.touch(temp_file)
	end
	# Get import history
	ih=get_valid_import_history()
	# Get import config
	ic=ih.import_config
	# Set new filetype
	ic.file_type='docx'
	# Import file
	result=ih.import_data(temp_file,ic,ih.user_id)
	# Test
	result.should == false
	# Errors should exist
	ih.errors.size.should > 0
	# Error message
	ih.errors.messages.to_s.should =~ /Unknown import filetype/i
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should generate an error when importing a non existing file" do
	# Get temp file name
	temp_file='aaa.txt'
	# Get import history
	ih=get_valid_import_history()
	# Get import config
	ic=ih.import_config
	# Set new filetype
	ic.file_type='docx'
	# Import file
	result=ih.import_data(temp_file,ic,ih.user_id)
	# Test
	result.should == false
	# Errors should exist
	ih.errors.size.should > 0
	# Error message
	ih.errors.messages.to_s.should =~ /File does not exist/i
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should use a pre_parser if it is specified" do
	# Import config attributes
	@attr_ic={:title => 'PreParserTest', :description => 'test pre_parser functionality', :field_mapping => {:date_purchased => 1, :amount => 3, :store => 2}, :file_type => 'csv', :unique_id_field => 0, :unique_id_hash_fields => [1,2,3], :date_type => 0,:pre_parser => 'test'}
	# Import file
	filename='spec/imports/pre_parser_test.csv'
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
	date_purchased.strftime("%Y-%m-%d").should == Date.parse('2015-01-19').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "85.00"
	# Check Store
	id1.mapped_fields[:store].should == "Store Title1"
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should raise an error if pre_parser does not exist" do
	# Import config attributes
	@attr_ic={:title => 'PreParserTest', :description => 'test pre_parser functionality', :field_mapping => {:date_purchased => 1, :amount => 3, :store => 2}, :file_type => 'csv', :unique_id_field => 0, :unique_id_hash_fields => [1,2,3], :date_type => 0,:pre_parser => 'not_exist'}
	# Import file
	filename='spec/imports/pre_parser_test.csv'
	# Get import history
	lambda {get_valid_import_history()}.should raise_error
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
	# Import data
	ih=import_pc
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
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should be able to import csv from capital one" do
	# Import config attributes
	@attr_ic=@attr_ic_capital_one_mc
	# Import file
	filename='spec/imports/capital_one_mc.csv'
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
	# ImportData should contain 4 new rows
	id.size.should == 4
	# Get first record
	id1=id.first
	# Get Date bought
	date_purchased=id1.mapped_fields[:date_purchased]
	# Check Date
	date_purchased.strftime("%Y-%m-%d").should == Date.parse('2015-01-19').strftime("%Y-%m-%d")
	# Check amount
	id1.mapped_fields[:amount].should == "85.00"
	# Check Store
	id1.mapped_fields[:store].should == "aaaaaa bbbbbbbbb"
	# Remove any saved files
	ih.remove_saved_file.should == true
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
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should be able to ignore duplicate entries during import with pre_parser" do
	# Import config attributes
	@attr_ic=@attr_ic_capital_one_mc
	# Import file
	filename='spec/imports/capital_one_mc.csv'
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
	id.size.should == 4
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
	id.size.should == 4
	# Test: errors should still be zero, because it's not an error
	ih2.errors.size.should == 0
	# Remove any saved files
	ih.remove_saved_file.should == true
    end

    it "should be able to import the same record by each user" do
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
	# Remove any saved files
	ih.remove_saved_file.should == true
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

    it "should have a method to remove it's saved file" do
	# Get instance
	ih=get_valid_import_history
	# Test
	ih.should respond_to(:remove_saved_file)
    end

    it "should be able to remove it's saved file" do
	# Info: this method if for testing only, not real world usage
	# Set target dir
	storage_dir=Dir.tmpdir
	# Get object
	ih=get_valid_import_history()
	# Set file content
	file_content='This is a test file content'
	# Save file
	result=ih.save_file(file_content,storage_dir)
	# Test
	result.should == true
	# Get full path
	file_path=File.join(ih.target_dir, ih.new_file_name)
	# Test: file is created
	File.exist?(file_path).should == true
	# Remove file
	ih.remove_saved_file.should == true
	# Test: file is removed
	File.exist?(file_path).should == false
    end

    it "should have a delete_imported_records method" do
	ih=get_valid_import_history
	# Test
	ih.should respond_to(:delete_imported_records)
    end

    it "should delete imported_records that have not been processed" do
	# First Import data
	ih1=import_amex
	# Get all ImportData
	id1=ImportDatum.all
	# ImportData should contain 3 new rows
	id1.size.should == 3
	# Second Import data
	ih2=import_pc
	# Get all ImportData
	id2=ImportDatum.all
	# ImportData should contain 2 new rows
	id2.size.should == 5
	# Test
	ih1.id.should_not == ih2.id
	id1.first.import_history_id.should_not == id2.last.import_history_id
	# Delete first import
	ih1.delete_imported_records(ih1.user_id)
	# Test
	ImportDatum.all.size.should == 2
	# Re-import
	ih3=import_amex
	# ImportData should contain 5 rows
	ImportDatum.all.size.should == 5
    end

    it "should not delete imported_records that have been processed" do
	# First Import data
	ih1=import_amex
	# Get all ImportData
	id1=ImportDatum.all
	# ImportData should contain 3 new rows
	id1.size.should == 3
	# Second Import data
	ih2=import_pc
	# Get all ImportData
	id2=ImportDatum.all
	# ImportData should contain 2 new rows
	id2.size.should == 5
	# Test
	ih1.id.should_not == ih2.id
	id1.first.import_history_id.should_not == id2.last.import_history_id
	# Get first record
	first=id1.first
	# Process first_record
	first.process_flag=true
	# Save first record
	first.save.should == true
	# Delete first import
	ih1.delete_imported_records(ih1.user_id)
	# Test: should have deleted only 2 rows, 3 left
	ImportDatum.all.size.should == 3
	# Re-import with same user
	ih3=import_amex(ih1.user_id)
	# ImportData should add 2 new rows (1 stayed there)
	ImportDatum.all.size.should == 5
    end

    it "should only delete imported_records if the user matches" do
	# First Import data
	ih1=import_amex
	# Get all ImportData
	id1=ImportDatum.all
	# ImportData should contain 3 new rows
	id1.size.should == 3
	# Get 2nd user
	u2=get_next_user
	# Test
	ih1.user_id.should_not == u2.id
	# Delete first import
	ih1.delete_imported_records(u2.id)
	# Test
	ImportDatum.all.size.should == 3
	# Delete using correct user
	ih1.delete_imported_records(ih1.id)
	# Test
	ImportDatum.all.size.should == 0
    end

    it "should have an error message if a user tries to delete another user's records" do
	# First Import data
	ih1=import_amex
	# Get all ImportData
	id1=ImportDatum.all
	# ImportData should contain 3 new rows
	id1.size.should == 3
	# Get 2nd user
	u2=get_next_user
	# Test
	ih1.user_id.should_not == u2.id
	# Delete first import
	result=ih1.delete_imported_records(u2.id)
	# Test
	result.should == false
	# Errors should exist
	ih1.errors.size.should > 0
	# Error message
	ih1.errors.messages.to_s.should =~ /Cannot delete other user's imported records./i
    end
end
