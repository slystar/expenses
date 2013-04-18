require 'spec_helper'

describe "Sessions" do

    before(:each) do
	# Create new user
	@user=get_user
	# Save user
	@user.save!
	# Visit signin page
	visit login_path
    end

    # Method to get user
    def get_user
	return User.new({:user_name => 'test_user',:password => '1234abcd', :name => 'test user'})
    end

    describe "new, create" do
	it "should login with valid attributes" do
	    # Fill in info
	    page.fill_in "user_name", with: @user.user_name
	    page.fill_in "password", with: @user.password
	    # Click button to submit
	    page.click_button "Log in"
	    # Test: Should redirect to menu
	    current_path.should == menu_path
	    # Test: Should have message
	    page.should have_content('Logged in')
	end

	it "should not login with bad attributes" do
	    # Fill in info
	    page.fill_in "user_name", with: @user.user_name
	    page.fill_in "password", with: @user.password + '1'
	    # Click button to submit
	    page.click_button "Log in"
	    # Test: Should redirect to menu
	    current_path.should == '/sessions'
	    # Test: Should have message
	    page.should have_content('Invalid user/password combination')
	end
    end

    describe 'destroy' do
	it "should logout" do
	    # Fill in info
	    page.fill_in "user_name", with: @user.user_name
	    page.fill_in "password", with: @user.password
	    # Click button to submit
	    page.click_button "Log in"
	    # Test: Should redirect to menu
	    current_path.should == menu_path
	    # Click logout
	    page.click_link 'Logout'
	    # Test: Should redirect to menu
	    current_path.should == login_path
	end
    end
end
