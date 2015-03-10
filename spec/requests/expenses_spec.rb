require 'spec_helper'

describe "Expenses ->" do

    describe 'requires login for ->' do

	it "menu" do
	    # Visit page
	    visit menu_path
	    # Test
	    current_path.should == login_path
	end

	it "import histories" do
	    # Visit page
	    visit import_histories_path
	    # Test
	    current_path.should == login_path
	end

	pending "test all pages" do
	end

    end

    describe 'after login ->' do

	before(:each) do
	    @new_user_id=0
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

	describe "Menu ->" do

	    describe "Logout ->" do
		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("Logout")
		end
	    end

	    describe "Edit user ->" do
		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("Edit user")
		end
	    end

	    describe "Edit groups ->" do
		pending "should have a link" do
		    visit(menu_path)
		    page.should have_link("Edit groups")
		end

		pending "should appear only for admins" do
		end
	    end

	    describe "View ->" do
		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("View expenses")
		end
		
		it "should display expenses" do
		    # Create expense
		    e=get_valid_expense
		    visit(expenses_path)
		    # Tests
		    page.should have_content("Listing expenses")
		    page.should have_button("Search")
		    page.should have_content(e.date_purchased.utc.to_date)
		    page.should have_content(e.description)
		    page.should have_content(e.pay_method.name)
		    page.should have_content(e.reason.name)
		    page.should have_content(e.store.name)
		    page.should have_content(e.user.user_name)
		    page.should have_content(e.group.name)
		    # Test: should have column filters
		    page.should have_select(:filter_store, :with_options => [e.store.name])
		    page.should have_select(:filter_pay_method, :with_options => [e.pay_method.name])
		    page.should have_select(:filter_reason, :with_options => [e.reason.name])
		    page.should have_select(:filter_user, :with_options => [e.user.user_name])
		    # Test: should have a reset filters link
		    page.should have_link("Reset filters")
		end
	    end

	    describe "Process duplicates ->" do
		pending "should show duplicates" do
		end
	    end


	    describe "Import expenses ->" do

		before(:each) do
		    @import_path="#{expenses_path}/import"
		    attr={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
		    @ic=get_valid_import_config(attr)
		    # Save ImportConfig
		    @ic.save
		end

		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("Import expenses")
		    visit(@import_path)
		    current_path.should == @import_path
		end

		it "should import expenses" do
		    visit(@import_path)
		    # Test
		    page.should have_content("Import expenses")
		    # Fill in information
		    page.select "Amex", from: 'file_upload_import_config'
		    page.attach_file 'file_upload_my_file', File.join(Rails.root, '/spec/imports/amex.csv')
		    # Test
		    ImportDatum.all.size.should == 0
		    # Click button to submit
		    page.click_button "Upload"
		    # Test
		    current_path.should == @import_path
		    ImportDatum.all.size.should == 3
		end

		it "should be able to undo imoprt" do
		    visit(@import_path)
		    # Test
		    page.should have_content("Import expenses")
		    # Fill in information
		    page.select "Amex", from: 'file_upload_import_config'
		    page.attach_file 'file_upload_my_file', File.join(Rails.root, '/spec/imports/amex.csv')
		    # Click button to submit
		    page.click_button "Upload"
		    # Test
		    current_path.should == @import_path
		    ImportDatum.all.size.should == 3
		    page.should have_link("Undo Import")
		    # Click link
		    page.click_link "Undo Import"
		    # Test
		    current_path.should == @import_path
		    ImportDatum.all.size.should == 0
		end
	    end


	    describe "Add expense ->" do

		before(:each) do
		    # Variables
		    @add_path="#{expenses_path}/new"
		    # Get a valid expense to create stores, etc
		    @e=get_valid_expense
		    # Visit page
		    visit @add_path
		end

		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("Add expense")
		end

		it "should be able to add a valid record" do
		    # Fill information
		    page.fill_in "expense_description", with: 'test description'
		    page.select @e.pay_method.name, from: 'expense_pay_method_id'
		    page.select @e.reason.name, from: 'expense_reason_id'
		    page.select @e.store.name, from: 'expense_store_id'
		    page.select @e.group.name, from: 'expense_group_id'
		    page.fill_in "expense_amount", with: 10
		    # Test: Record created
		    lambda{
			page.click_button 'Create Expense'
		    }.should change(Expense,:count).by(1)
		    # Test: path
		    current_path.should == @add_path
		end

		it "shold show an error with invalid attributes" do
		    # Fill information
		    page.fill_in "expense_description", with: 'test description'
		    page.select @e.pay_method.name, from: 'expense_pay_method_id'
		    page.select @e.reason.name, from: 'expense_reason_id'
		    page.select @e.group.name, from: 'expense_group_id'
		    page.fill_in "expense_amount", with: 10
		    # Test: Record created
		    lambda{
			page.click_button 'Create Expense'
		    }.should change(Expense,:count).by(0)
		    # Test: path
		    page.should have_content("Store can't be blank")
		end

		pending "should show a warning on possible duplicate entry" do
		end

		pending "should show a warning if date is in the future" do
		end

		it "should only show visible groups" do
		    # Variables
		    group_name='zzz'
		    # Add group
		    new_group=Group.new({:name => group_name})
		    # Save
		    new_group.save!
		    # Re-visit page
		    visit @add_path
		    # Test: should show up in select
		    page.has_select?(:expense_group_id, :with_options => [group_name]).should == true
		    # Set hidden to true
		    new_group.hidden=true
		    # Save group
		    new_group.save
		    # Re-visit page
		    visit @add_path
		    # Test: should show up in select
		    page.has_select?(:expense_group_id, :with_options => [group_name]).should == false
		end

		describe 'add pay method ->' do
		    before(:each) do
			# Variables
			@test_description='test desc'
			@new_pay_method='zzz'
			# Fill some info
			page.fill_in "expense_description", with: @test_description
			page.select @e.reason.name, from: 'expense_reason_id'
		    end

		    def add_pay_method(name,record_increase)
			# Add another item
			page.click_button 'Add Pay Method'
			# Fill in info
			page.fill_in "pay_method_name", with: name
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(PayMethod,:count).by(record_increase)
		    end

		    it "should be able to add pay_method" do
			# Add item
			add_pay_method(@new_pay_method,1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Pay method was successfully created')
			page.should have_content(@test_description)
			find_field('expense_pay_method_id').find('option[selected]').text.should == @new_pay_method
			find_field('expense_reason_id').find('option[selected]').text.should == @e.reason.name
		    end

		    it "should show an error message when adding an invalid pay method" do
			# Add item
			add_pay_method(@new_pay_method,1)
			# Add another item
			add_pay_method(@new_pay_method,0)
			# Test: should redirect to add expense
			current_path.should == "#{pay_methods_path}"
			page.should have_content('Name has already been taken')
		    end

		    it "should allow adding a corrected invalid pay method" do
			# 2nd message
			item2=@new_pay_method + 'a'
			# Add item
			add_pay_method(@new_pay_method,1)
			# Add existing item
			add_pay_method(@new_pay_method,0)
			# Test: should redirect to add expense
			current_path.should == "#{pay_methods_path}"
			page.should have_content('Name has already been taken')
			# Change name
			page.fill_in "pay_method_name", with: item2
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(PayMethod,:count).by(1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Pay method was successfully created')
			page.should have_content(@test_description)
			find_field('expense_pay_method_id').find('option[selected]').text.should == item2
			find_field('expense_reason_id').find('option[selected]').text.should == @e.reason.name
		    end
		end

		describe 'add reason ->' do
		    before(:each) do
			# Variables
			@test_description='test desc'
			@new_reason='zzz'
			# Fill some info
			page.fill_in "expense_description", with: @test_description
			page.select @e.pay_method.name, from: 'expense_pay_method_id'
		    end

		    def add_reason(name,record_increase)
			# Add another item
			page.click_button 'Add Reason'
			# Fill in info
			page.fill_in "reason_name", with: name
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(Reason,:count).by(record_increase)
		    end

		    it "should be able to add reason" do
			# Add item
			add_reason(@new_reason,1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Reason was successfully created')
			page.should have_content(@test_description)
			find_field('expense_reason_id').find('option[selected]').text.should == @new_reason
			find_field('expense_pay_method_id').find('option[selected]').text.should == @e.pay_method.name
		    end

		    it "should show an error message when adding an invalid reason" do
			# Add item
			add_reason(@new_reason,1)
			# Add another item
			add_reason(@new_reason,0)
			# Test: should redirect to add expense
			current_path.should == "#{reasons_path}"
			page.should have_content('Name has already been taken')
		    end

		    it "should allow adding a corrected invalid reason" do
			# 2nd message
			item2=@new_reason + 'a'
			# Add item
			add_reason(@new_reason,1)
			# Add existing item
			add_reason(@new_reason,0)
			# Test: should redirect to add expense
			current_path.should == "#{reasons_path}"
			page.should have_content('Name has already been taken')
			# Change name
			page.fill_in "reason_name", with: item2
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(Reason,:count).by(1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Reason was successfully created')
			page.should have_content(@test_description)
			find_field('expense_reason_id').find('option[selected]').text.should == item2
			find_field('expense_pay_method_id').find('option[selected]').text.should == @e.pay_method.name
		    end
		end

		describe 'add store ->' do
		    before(:each) do
			# Variables
			@test_description='test desc'
			@new_store='zzz'
			# Fill some info
			page.fill_in "expense_description", with: @test_description
			page.select @e.pay_method.name, from: 'expense_pay_method_id'
		    end

		    def add_store(name,record_increase)
			# Add another item
			page.click_button 'Add Store'
			# Fill in info
			page.fill_in "store_name", with: name
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(Store,:count).by(record_increase)
		    end

		    it "should be able to add Store" do
			# Add item
			add_store(@new_store,1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Store was successfully created')
			page.should have_content(@test_description)
			find_field('expense_store_id').find('option[selected]').text.should == @new_store
			find_field('expense_pay_method_id').find('option[selected]').text.should == @e.pay_method.name
		    end

		    it "should show an error message when adding an invalid store" do
			# Add item
			add_store(@new_store,1)
			# Add another item
			add_store(@new_store,0)
			# Test: should redirect to add expense
			current_path.should == "#{stores_path}"
			page.should have_content('Name has already been taken')
		    end

		    it "should allow adding a corrected invalid store" do
			# 2nd message
			item2=@new_store + 'a'
			# Add item
			add_store(@new_store,1)
			# Add existing item
			add_store(@new_store,0)
			# Test: should redirect to add expense
			current_path.should == "#{stores_path}"
			page.should have_content('Name has already been taken')
			# Change name
			page.fill_in "store_name", with: item2
			# Test:
			lambda{
			    page.click_button "Save"
			}.should change(Store,:count).by(1)
			# Test: should redirect to add expense
			current_path.should == "#{expenses_path}/new"
			page.should have_content('Store was successfully created')
			page.should have_content(@test_description)
			find_field('expense_store_id').find('option[selected]').text.should == item2
			find_field('expense_pay_method_id').find('option[selected]').text.should == @e.pay_method.name
		    end
		end
	    end

	    describe "Import Histories ->" do
		before(:each) do
		    @import_histories_path="#{import_histories_path}"
		end
		it "should have a link" do
		    visit(menu_path)
		    page.should have_link("Import histories")
		    visit(@import_histories_path)
		    current_path.should == @import_histories_path
		end
	    end
	end
    end
end
