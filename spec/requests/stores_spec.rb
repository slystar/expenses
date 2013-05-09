require 'spec_helper'

describe "Stores:" do
    before(:each) do
	@add_path="#{stores_path}/new"
    end
    describe 'requires login for' do

	it "new" do
	    # Visit page
	    visit @add_path
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

	describe "add" do
	    before(:each) do
		visit @add_path
	    end

	    it "should add a valid record" do
		# Get expense object
		e=get_valid_expense
		page.fill_in "store_name", with: 'zzz'
		# Test:
		lambda{
		    page.click_button "Save"
		}.should change(Store,:count).by(1)
		# Test: should redirect to add expense
		current_path.should == "#{expenses_path}/new"
	    end
	end
    end
end
