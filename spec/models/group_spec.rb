require 'spec_helper'

describe Group do

    before(:each) do
	@attr={:name => "Group 1", :description => 'group 1 desc'}
	@attr_expense={:date_purchased => Time.now, :store_id => 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    def create_expense_with_group()
	@group=Group.create!(@attr)
	@expense=get_valid_expense
	@expense.group=@group
	@expense.save
	return @expense
    end
    it "should create a new instance given valid attributes" do
	Group.create!(@attr)
    end

    it "should have a default app_version" do
	object=Group.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=Group.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a name" do
	group=Group.new(@attr.merge(:name => ""))
	group.should_not be_valid
    end

    it "should have a unique name" do
	Group.create!(@attr)
	group=Group.new(@attr)
	group.should_not be_valid
    end

    it "should have a unique name, case insensitive" do
	g1=Group.create!(@attr)
	name=g1.name
	g2=group=Group.new(@attr.merge(:name =>name.upcase))
	g1.name.should_not == g2.name
	group.should_not be_valid
    end

    it "should be unique, case insensitive" do
	Group.create!(@attr)
	upcased=@attr.inject({}) { |h, (k, v)| h[k] = v.upcase; h }
	group=Group.new(upcased)
	upcased.should_not == @attr and group.should_not be_valid
    end

    it "should have a maximum of characters" do
	group=Group.new(@attr.merge(:name => "a" * 51))
	group.should_not be_valid
    end

    it "should have hidden false on creation" do
	g=Group.create!(@attr)
	g.hidden.should == false
    end

    it "should respond to expenses" do
	group=Group.new(@attr)
	group.should respond_to(:expenses)
    end

    it "should have expenses attributes" do
	expense=create_expense_with_group
	group=expense.group
	group_other=Group.create!(@attr.merge(:name => Faker::Name.name))
	group_other.add_user(@expense.user)
	Expense.create!(@attr_expense.merge(:group_id => group.id))
	Expense.create!(@attr_expense.merge(:group_id => group_other.id))
	@group.expenses.size.should == 2
    end

    it "should have the right associated expense" do
	expense=create_expense_with_group
	@group.should == expense.group
    end

    it "should not be destroyed if group has expenses" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.should_not be_destroyed
    end

    it "should have an error if it has expenses and destroy is called" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.errors.size.should == 1
    end

    it "should have an error containing model name if it has expenses and destroy is called" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.errors.messages.values.flatten.grep(/Group/).size.should > 0
    end

    it "should be destroyable if group has no expenses" do
	expense=create_expense_with_group
	group=expense.group
	expense.destroy
	# remove users
	group.user_ids=[]
	group.destroy
	group.should be_destroyed
    end

    it "should not be able to destroy group with users in it" do
	group=Group.create!(@attr)
	u1=User.create!(:user_name => 'user1', :password => 'testpasswordgroup')
	group.users << u1
	group.destroy
	group.errors.size.should == 1
	group.should_not be_destroyed
    end

    it "should be destroyable if it's empty" do
	group=Group.create!(@attr)
	group.destroy
	group.should be_destroyed
    end

    it "should provide the Group.users function" do
	group=Group.create!(@attr)
	u1=User.create!(:user_name => 'user1', :password => 'testpasswordgroup')
	u2=User.create!(:user_name => 'user2', :password => 'testpasswordgroup')
	group.users << u1
	group.users << u2
	group.users.size.should == 2
    end

    it "should respond to 'add_user' method" do
	group=Group.new(@attr)
	group.should respond_to(:add_user)
    end

    it "should be able to add a user to group" do
	# Create new user
	u1=User.create!(:user_name => 'user10', :password => 'testpasswordgroup')
	# Create group
	group=Group.create!(@attr)
	lambda{
	    # Add user
	    group.add_user(u1)
	}.should change(GroupMember,:count).by(1)
    end

    it "should be able to add multiple users to group" do
	# Create new user
	u1=User.create!(:user_name => 'user10', :password => 'testpasswordgroup')
	u2=User.create!(:user_name => 'user11', :password => 'testpasswordgroup')
	# Create group
	group=Group.create!(@attr)
	lambda{
	    # Add user
	    group.add_user(u1)
	    group.add_user(u2)
	}.should change(GroupMember,:count).by(2)
    end

    it "should not allow a duplicate add_user entry" do
	# Create new user
	u1=User.create!(:user_name => 'user10', :password => 'testpasswordgroup')
	# Create group
	group=Group.create!(@attr)
	lambda{
	    # Add user
	    group.add_user(u1)
	}.should change(GroupMember,:count).by(1)
	# Refresh user
	u1.reload
	# Add duplicate entry
	lambda{
	# Add user
	    group.add_user(u1)
	}.should change(GroupMember,:count).by(0)
	# There should be an error
	group.errors.size.should > 0
    end
end
