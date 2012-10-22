require 'spec_helper'

describe User do

    before(:each) do
	@attr={:user_name => 'test', :password => 'testpassword'}
	@attr_group={:name => "Group user spec", :description => 'group used in user spec tests'}
    end

     it "should create a new instance given valid attributes" do
	 User.create!(@attr)
     end

    it "should have a user_name" do
	user=User.new(@attr.merge(:user_name => ""))
	user.should_not be_valid
    end

    it "should have a unique user_name" do
	User.create!(@attr)
	user=User.new(@attr)
	user.should_not be_valid
    end

    it "should have a unique user_name, case insensitive" do
	u1=User.create!(@attr)
	# Get username
	name=u1.user_name
	# Create 2nd user
	u2=User.new(@attr.merge(:user_name => name.upcase))
	# Make sure they are not the same
	u1.user_name.should_not == u2.user_name
	# Make sure it's unique
	u2.should_not be_valid
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

    it "should not be destroyable if it has expenses through groups other than ALL" do
	puts
	expense=get_valid_expense
	user=User.create!(@attr)
	group=Group.create!(@attr_group)
	# Create group membership
	attr_group_member={:user_id => user.id, :group_id => group.id}
	GroupMember.create!(attr_group_member)
	# Set expense to use this group
	expense.group_id=group.id
	# Save expense
	expense.save
	# User should be part of the group
	user.groups.should include(group)
	# Try to destroy user
	user.destroy
	user.errors.size.should > 0
	user.should_not be_destroyed
    end

    it "should have default group destroyed on destruction" do
	# Create user
	user=User.create!(@attr)
	# Get all groups count
	groups1=Group.all.size
	# Destroy user
	user.destroy
	# Check if user is destroyed
	user.should be_destroyed
	# Get all groups count
	groups2=Group.all.size
	# Count should be one less
	(groups1 - groups2).should == 1
	# Get default group
	default_group=Group.where(:name => user.user_name)
	# Default group should not exist
	default_group.size.should == 0
    end

    it "should have all group memberships removed on destruction" do
	# Create user
	user=User.create!(@attr)
	# Destroy user, should remove following memberships
	# - group: ALL
	# - group: User
	lambda{user.destroy}.should change(GroupMember,:count).by(-2)
    end
end
