require 'spec_helper'

describe "ImportHistories:" do

    before(:each) do
	@attr={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@attr_ic={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
	@new_user_id=0
    end

    describe 'requires login for' do

	it "show" do
	    # Get ih
	    ih=get_valid_import_history
	    # Save
	    ih.save.should == true
	    # Variables
	    path="#{import_histories_path}/#{ih.id}"
	    # Visit page
	    visit path
	    # Test
	    current_path.should == login_path
	end

	it "index" do
	    # Get ih
	    ih=get_valid_import_history
	    # Save
	    ih.save.should == true
	    # Variables
	    path="#{import_histories_path}"
	    # Visit page
	    visit path
	    # Test
	    current_path.should == login_path
	end

    end

    describe 'after login' do

	before(:each) do
	    # Get user
	    @user=get_next_user
	    # Create user
	    @user.save!
	    # Login
	    login_user(@user)
	end

	def login_user(user)
	    # Visit login page
	    visit login_path
	    # Fill in info
	    page.fill_in "user_name", with: user.user_name
	    page.fill_in "password", with: user.password
	    # Click button to submit
	    page.click_button "Log in"
	end

	describe "show" do
	    it "should display a valid record" do
		# Get ih
		ih=get_valid_import_history
		# Save
		ih.save.should == true
		# Variables
		path="#{import_histories_path}/#{ih.id}"
		# Visit page
		visit path
		# Test
		page.should have_content("Import History")
		page.should have_content("id")
		page.should have_content(ih.id)
		page.should have_content(ih.app_version)
	    end
	end

	describe "index" do
	    before(:each) do
		@index_path="#{import_histories_path}"
	    end

	    # Method to add import records
	    def add_import_records(user_id)
		# Variables
		attr_ih={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
		@attr_ic={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
		# Get import history
		ih=get_valid_import_history(attr_ih)
		# Import file
		@filename='spec/imports/amex.csv'
		# Set suer
		ih.user_id=user_id
		# Save import_history
		ih.save!
		# Get import config
		ic=ih.import_config
		# Get user
		u=user_id
		# Import data
		ih.import_data(@filename,ic,u)
		# Save record
		ih.save
		# Test
		ImportDatum.all.size.should == 3
		# return record
		return ih
	    end

	    def remove_imported_records(ih)
		# Remove any saved files
		ih.remove_saved_file.should == true
	    end

	    it "should display a list of import_histories" do
		# Get ih
		ih=get_valid_import_history
		# Save
		ih.save.should == true
		# Get ih
		ih2=get_valid_import_history
		# Save
		ih2.save.should == true
		# Visit page
		visit @index_path
		# Test
		ih.id.should_not == ih2.id
		page.current_path.should == import_histories_path
		page.should have_content("Listing import histories")
		page.should have_content("id")
		page.should have_content(ih.id)
		page.should have_content(ih2.id)
	    end

	    it "should allow to undo an import" do
		# Create import
		ih=add_import_records(@user.id)
		# Visit page
		visit @index_path
		# Click delete imported records
		page.click_link 'Delete Imported records'
		# Test
		page.current_path.should == @index_path
		ImportDatum.all.size.should == 0
		page.should have_content("Errased all imported records for ImportHistory id:#{ih.id}")
	    end

	    it "should not allow one user to undo import of another user" do
		# Get second user
		u2=get_next_user
		# Create import
		ih=add_import_records(u2.id)
		# Test
		u2.id.should_not == @user.id
		# Visit page
		visit @index_path
		# Click delete imported records
		page.click_link 'Delete Imported records'
		# Test
		page.current_path.should == @index_path
		ImportDatum.all.size.should_not == 0
		page.should have_content("Cannot delete other user's imported records.")
	    end
	end
    end
end
