require 'spec_helper'

describe "Users" do

    # Method to get user
    def get_user
	@new_user_id=1
	return User.new({:user_name => 'test_user',:password => '1234abcd', :name => 'test user'})
    end

    describe 'new, create (Sign up)' do

	before(:each) do
	    # Create new user
	    @user=get_user
	    # Visit signup page
	    visit signup_path
	end

	def submit_new_user
	    # Fill in info
	    page.fill_in "user_user_name", with: @user.user_name
	    page.fill_in "user_password", with: @user.password
	    page.fill_in "user_password_confirmation", with: @user.password
	    page.fill_in "user_name", with: @user.name
	    # Click button to submit
	    page.click_button "Create User"
	end

	it "should work with valid input" do
	    # Fill in info
	    submit_new_user
	    # Test: Should redirect to menu
	    current_path.should == menu_path
	    # Test: Should have a notice
	    page.should have_content('User was successfully created.')
	end

	it "should display en error when bad input is given" do
	    # Create user
	    @user.save!
	    # Fill in info
	    page.fill_in "user_user_name", with: @user.user_name
	    page.fill_in "user_password", with: '123'
	    page.fill_in "user_password_confirmation", with: '12345678'
	    page.fill_in "user_name", with: @user.name
	    # Click button to submit
	    page.click_button "Create User"
	    # Test: Should not redirect
	    current_path.should == users_path
	    # Test: Should have a notice div
	    page.should_not have_selector('div.alert.alert-error')
	    page.should have_content('User name has already been taken')
	    page.should have_content('Password is too short')
	    page.should have_content("Password doesn't match confirmation")
	end

	it "should add first user to admin role" do
	    # Fill in info
	    submit_new_user
	    # Get user
	    user=User.find(:first, :conditions => {:user_name=> @user.user_name})
	    # Test
	    user.roles.keep_if{|r| r.name == 'Admin'}.size.should == 1
	end

	it "should not add user 2 or more to admin role" do
	    # Create 1st user
	    user1=@user.dup
	    user1.user_name=@user.user_name + '1'
	    user1.save!
	    # Fill in info
	    submit_new_user
	    # Get user
	    user=User.find(:first, :conditions => {:user_name=> @user.user_name})
	    # Test
	    user.roles.keep_if{|r| r.name == 'Admin'}.size.should == 0
	end

	describe "layout" do
	    it { page.should have_selector('h1', text: 'Sign up') }

	    it "should have the proper tile" do
		first('head title').native.text.should == 'Expenses'
	    end

	    it "should have proper input fields" do
		# Variables
		expected_input_types={"hidden"=>1, "text"=>2, "password"=>2, "submit"=>1}
		found_input_types={}
		# Input: text
		page.should have_field('user_user_name')
		page.should have_field('name')
		page.all('input[type=text]').size.should == 2
		# Input: password
		page.should have_field('user_password')
		page.should have_field('user_password_confirmation')
		page.all('input[type=password]').size.should == 2
		# check all input fields
		page.all('input').each do |e|
		    # Get nokogiri object
		    nok=e.native
		    # Get attributes
		    attributes=nok.attributes
		    # Loop over attributes
		    attributes.each do |x|
			# Get type
			type=x[0]
			value=x[1].value
			# Process only 'type'
			next if type != 'type'
			# Create hash if it does not exist
			found_input_types[value]=0 if found_input_types[value].nil?
			# Add to count
			found_input_types[value] += 1
		    end
		end
		expected_input_types.should == found_input_types
	    end
	end
    end

    describe 'requires login for' do

	it "index" do
	    # Visit page
	    visit "#{users_path}"
	    # Test
	    current_path.should == login_path
	end

	it 'show' do
	    # Create user
	    user=get_user
	    # Save user
	    user.save!
	    # Visit page
	    visit "#{users_path}/#{user.id}"
	    # Test
	    current_path.should == login_path
	end

	it 'update' do
	    # Create user
	    user=get_user
	    # Save user
	    user.save!
	    # Visit page
	    visit "#{users_path}/#{user.id}/edit"
	    # Test
	    current_path.should == login_path
	end

	it 'edit' do
	    # Create user
	    user=get_user
	    # Save user
	    user.save!
	    # Visit page
	    visit "#{users_path}/#{user.id}/edit"
	    # Test
	    current_path.should == login_path
	end
    end


    describe 'after login' do

	before(:each) do
	    # Get user
	    @user=get_user
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

	describe 'index' do

	    before(:each) do
		# Visit signup page
		visit users_path
	    end

	    it "should be index page" do
		# Test
		page.should have_link 'New User'
		page.should have_content 'Listing users'
	    end

	    it "should require admin role" do
		# Get 2nd user
		user2=get_next_user
		# Login second user
		login_user(user2)
		# Visit users path
		visit users_path
		# Test: Should redirect to menu
		current_path.should == menu_path
		page.should have_content "requires admin role"
	    end
	end

	describe 'edit' do
	    pending "should require admin role"
	end

	describe 'show' do
	    pending "should display current logged in user"
	end

	describe 'update' do
	    pending "should not allow a change of user_name"
	    pending "should allow a change of name"
	    pending "should allow a change of password"
	end

	describe 'destroy' do
	    pending "should not exist"
	end
    end
end
