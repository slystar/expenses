require 'spec_helper'

describe SessionsHelper do

  it "Should have a sign_in method" do
    # Create user
    u=get_valid_new_user
    u.save!
    # Sign in (user already authenticated)
    helper.sign_in(u)
    # Test
    helper.current_user.should == u
    session[:user_id].should == u.id
  end

  it "should have a signed_in? method" do
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

  pending "current_user=(user)"
  pending "current_user"
  pending "current_user?(user)"
  pending "signed_in_user"
  pending "sign_out"
  pending "redirect_back_or(default)"
  pending "store_location"
end
