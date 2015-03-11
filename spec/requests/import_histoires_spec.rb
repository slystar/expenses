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
	    it "should display a list of import_histories" do
		# Get ih
		ih=get_valid_import_history
		# Save
		ih.save.should == true
		# Get ih
		ih2=get_valid_import_history
		# Save
		ih2.save.should == true
		# Variables
		path="#{import_histories_path}"
		# Visit page
		visit path
		# Test
		ih.id.should_not == ih2.id
		page.current_path.should == import_histories_path
		page.should have_content("Listing import histories")
		page.should have_content("id")
		page.should have_content(ih.id)
		page.should have_content(ih2.id)
	    end

	    pending "should allow to undo an import" do
	    end
	end
    end
end
