require 'spec_helper'

describe User do

    before(:each) do
	@attr={:user_name => 'test', :password => 'test'}
    end

     it "should create a new instance given valid attributes" do
	 User.create!(@attr)
     end

    it "should have a unique user_name" do
	User.create!(@attr)
	user=User.new(@attr)
	user.should_not be_valid
    end

    it "should have a user_name" do
	user=User.new(@attr.merge(:user_name => ""))
	user.should_not be_valid
    end

    it "should have a password_digest" do
	user=User.new(@attr.merge(:password => ""))
	user.should_not be_valid
    end
end
