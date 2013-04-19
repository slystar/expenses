require 'spec_helper'

describe SessionsHelper do

    before(:each) do
	@new_user_id = 1
    end

    def get_logged_in_user
	# Create user
	u=get_valid_new_user
	u.save!
	# Sign in (user already authenticated)
	helper.sign_in(u)
	# Return user
	return u
    end

    it "Should have method: sign_in" do
	# Log in user
	u=get_logged_in_user
	# Test
	session[:user_id].should == u.id
    end

    it "should have method: signed_in?" do
	# Create user
	u=get_valid_new_user
	u.save!
	# Test: User should not be signed in yet
	helper.signed_in?.should == false
	# Sign in user
	helper.sign_in(u)
	# Test: User should now be signed in
	helper.signed_in?.should == true
    end

    it "should have method: login_required" do
	# Test
	helper.should respond_to(:login_required)
    end

    it "should have method: sign_out" do
	# Log in user
	u=get_logged_in_user
	# Test
	helper.should respond_to(:sign_out)
	# Sign out
	helper.sign_out
	# Test
	session[:user_id].should == nil
    end

    it "should have method: redirect_back_or" do
	# Log in user
	u=get_logged_in_user
	# Test
	helper.should respond_to(:redirect_back_or)
    end

    it "should have method: store_location" do
	# Log in user
	u=get_logged_in_user
	# Test
	helper.should respond_to(:store_location)
	session[:return_to].should be_nil
    end

    it "should have method: is_admin?" do
	# Log in user
	u=get_logged_in_user
	# Test
	helper.should respond_to(:is_admin?)
	helper.is_admin?.should == true
    end
end
