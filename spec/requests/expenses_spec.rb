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

	    pending "shold show an error with invalid attributes" do
	    end
	end
    end
end
