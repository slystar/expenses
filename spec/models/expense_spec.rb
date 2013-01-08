require 'spec_helper'

describe Expense do

    before(:each) do
	@attr=get_attr_expense
    end

    it "should create a record with valid attributes" do
	Expense.create!(@attr)
    end

    it "should have a date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => nil))
	expense.should_not be_valid
    end

    it "should accept a date for date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => '2011-10-14'))
	expense.should be_valid
    end

    it "should refuse invalid dates for date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => '2011 10 14 aaa'))
	expense.should_not be_valid
    end

    it "should have a store" do
	expense=Expense.new(@attr.merge(:store_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing store" do
	expense=Expense.new(@attr)
	expense.store_id=9990000000
	expense.should_not be_valid
    end

    it "should have a pay_method" do
	expense=Expense.new(@attr.merge(:pay_method_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing pay_method" do
	expense=Expense.new(@attr)
	expense.pay_method_id=9990000000
	expense.should_not be_valid
    end

    it "should have a reason" do
	expense=Expense.new(@attr.merge(:reason_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing reason" do
	expense=Expense.new(@attr)
	expense.reason_id=9990000000
	expense.should_not be_valid
    end

    it "should have a user_id" do
	expense=Expense.new(@attr.merge(:user_id => nil))
	expense.should_not be_valid
    end

    it "should map to an existing user" do
	expense=Expense.new(@attr)
	expense.user_id=9990000000
	expense.should_not be_valid
    end

    it "should have a group_id" do
	expense=Expense.new(@attr.merge(:group_id => nil))
	expense.should_not be_valid
    end

    it "should map to an existing group" do
	expense=Expense.new(@attr)
	expense.group_id=9990000000
	expense.should_not be_valid
    end

    it "should have an amount" do
	expense=Expense.new(@attr)
	expense.amount=nil
	expense.should_not be_valid
    end

    it "should allow a single decimal in amount" do
	expense=Expense.new(@attr)
	expense.amount="1.5"
	expense.should be_valid
    end

    it "should not allow more than 2 decimal places in amount" do
	expense=Expense.new(@attr)
	expense.amount="1.567"
	expense.should_not be_valid
    end

    it "should not accept negative amounts" do
	expense=Expense.new(@attr)
	expense.amount="-1.567"
	expense.should_not be_valid
    end

    it "should not allow letters in amount" do
	expense=Expense.new(@attr)
	expense.amount="aa15"
	expense.should_not be_valid
    end

    it "should not be created with a process date" do
	expense=Expense.new(@attr)
	expense.process_date=Time.now
	expense.should_not be_valid
    end

    it "should allow a process date once it's been saved" do
	expense=Expense.create!(@attr)
	expense.process_date=Time.now
	expense.should be_valid
    end

    it "should not be created with process flag set to true" do
	expense=Expense.new(@attr)
	expense.process_flag=true
	expense.should_not be_valid
    end

    it "should allow to set process_flag once it's been saved" do
	expense=Expense.create!(@attr)
	expense.process_flag=true
	expense.should be_valid
    end

    it "should not be destroyable if it's been processed" do
	expense=Expense.create!(@attr)
	expense.process_flag=true
	expense.destroy
	expense.should_not be_destroyed
    end

    it "should be destroyable if it has not been processed" do
	expense=Expense.create!(@attr)
	expense.destroy
	expense.should be_destroyed
    end

    it "should be modifyable if it has not been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Modify
	expense.amount=99.99
	# Should save
	expense.save.should == true
    end

    it "should respond to a 'process' method" do
	# Create expense
	expense=Expense.create!(@attr)
	# Test
	expense.should respond_to(:process)
    end

    it "should be able to process itself" do
	# Variables
	amount=22.00
	# Get today
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Create users
	u1=User.create!({:user_name => 'test90', :password => 'testpassword'})
	u2=User.create!({:user_name => 'test91', :password => 'testpassword'})
	u3=User.create!({:user_name => 'test92', :password => 'testpassword'})
	users=[u1,u2,u3]
	# Create group
	group=Group.create!({:name => "Group test", :description => 'group 1 desc'})
	# Add user to group
	group.add_user(u1)
	group.add_user(u2)
	group.add_user(u3)
	# Create expense
	expense=Expense.new(@attr)
	# Set group
	expense.group_id=group.id
	# Set amount
	expense.amount=amount
	# Save expense
	expense.save!
	# Test: UserDept created
	lambda{
	    # Process record
	    expense.process
	}.should change(UserDept,:count).by(3)
	# Reload expense
	expense.reload
	# Test: Check UserDept
	users.each do |u|
	    # Get UserDept
	    ud=UserDept.where(:from_user_id => expense.user_id).where(:to_user_id => u.id).last
	    # Test
	    ud.amount.should == amount / users.size
	end
	# Test: UserBalance Created
	users.each do |u|
	    # Get UserDept
	    ub=UserBalance.where(:from_user_id => expense.user_id).where(:to_user_id => u.id).last
	    # Test
	    ub.amount.should == amount / users.size
	end
	# Test process fields
	expense.process_flag.should == true
	expense.process_date.strftime("%Y-%m-%d").should == today
    end

    it "should not be modifyable if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Process record (not decided how to proceed with this yet)
	expense.process
	# Reload
	expense.reload
	# Modify
	expense.amount=99.99
	# Should save
	expense.save.should == false
    end

    it "should respond to user_dept" do
	# Create expense
	expense=Expense.create!(@attr)
	# Test
	expense.should respond_to(:user_dept)
    end

    pending "should have a user dept method" do
    end

    pending "should have a user credit method" do
    end

    pending "should have a balances method" do
    end

    pending "should notify user about updates"
    pending "should process floats correctly"
    pending "should process integers correctly"
end
