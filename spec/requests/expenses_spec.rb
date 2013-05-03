require 'spec_helper'

describe "Expenses" do

    describe 'requires login for' do

	it "menu" do
	    # Visit page
	    visit menu_path
	    # Test
	    current_path.should == login_path
	end

    end

    describe 'after login' do

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

	it "should have a menu page with required links" do
	    # Visit page
	    visit(menu_path)
	    # Test
	    page.should have_link("Add expense")
	    page.should have_link("Edit user")
	    page.should have_link("Logout")
	end

	describe "Add" do

	    before(:each) do
		# Variables
		@add_path="#{expenses_path}/new"
		# Get a valid expense to create stores, etc
		@e=get_valid_expense
		# Visit page
		visit @add_path
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

	    describe 'add pay method' do
		before(:each) do
		    # Variables
		    @test_description='test desc'
		    @new_pay_method='zzz'
		    @path_add_pay_method="#{pay_methods_path}/new"
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
		    pay_method2=@new_pay_method + 'a'
		    # Add item
		    add_pay_method(@new_pay_method,1)
		    # Add existing item
		    add_pay_method(@new_pay_method,0)
		    # Test: should redirect to add expense
		    current_path.should == "#{pay_methods_path}"
		    page.should have_content('Name has already been taken')
		    # Change name
		    page.fill_in "pay_method_name", with: pay_method2
		    # Test:
		    lambda{
			page.click_button "Save"
		    }.should change(PayMethod,:count).by(1)
		    # Test: should redirect to add expense
		    current_path.should == "#{expenses_path}/new"
		    page.should have_content('Pay method was successfully created')
		    page.should have_content(@test_description)
		    find_field('expense_pay_method_id').find('option[selected]').text.should == pay_method2
		    find_field('expense_reason_id').find('option[selected]').text.should == @e.reason.name
		end
	    end
	end
    end
end
