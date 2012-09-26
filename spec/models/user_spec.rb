require 'spec_helper'

describe User do

    before(:each) do
	@attr={:user_name => 'test', :password => 'testpassword'}
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

    it "should have a password" do
	user=User.new(@attr.merge(:password => ""))
	user.should_not be_valid
    end

    it "should have a password with minimum 8 characters" do
	user=User.new(@attr.merge(:password => "a" * 7))
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

    it "should have a User.groups method" do
	user=User.create!(@attr)
	user.should respond_to(:groups)
    end

    it "should add a new user to the default ALL group" do
	user=User.create!(@attr)
	group=Group.where(:name => 'ALL').first
	found_user=group.users.detect{|u| u.user_name == user.user_name}
	found_user.should == user
    end

    it "should have a method expenses" do
	user=User.create!(@attr)
	user.should respond_to(:expenses)
    end

    it "should not be destroyable if it has expenses" do
	expense=get_valid_expense
	user=User.create!(@attr)
	expense.user=user
	expense.save
	user.destroy
	user.should_not be_destroyed
    end

    pending "should not be destroyable if it has expenses through groups" do
    end

    pending "should have default group destroyed on destruction" do
    end

    pending "should have all group memberships removed on destruction" do
    end
end
