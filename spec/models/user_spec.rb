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

    it "should have a default group upon creation" do
	user=User.create!(@attr)
	group=user.groups.find{|g| g.name == user.user_name}
	group.should_not be_nil
    end

    it "should be in a minimum of groups on creation" do
	user=User.create!(@attr)
	user.groups.size.should == 2
    end

    pending "should have a User.groups method" do
    end

    pending "should add a new user to the default ALL group" do
    end

    pending "should not be destroyable if it has expenses" do
    end

    pending "should have default group destroyed on destruction" do
    end

    pending "should have all group memberships removed on destruction" do
    end
end
