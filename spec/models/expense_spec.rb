require 'spec_helper'

describe Expense do

    before(:each) do
	@attr=get_attr_expense
	@new_user_id = 1
    end

    it "should create a record with valid attributes" do
	Expense.create!(@attr)
    end

    it "should have a default app_version" do
	object=Expense.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=Expense.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should have a date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => nil))
	expense.should_not be_valid
    end

    it "should accept a date for date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => '2011-10-14'))
	expense.should be_valid
    end

    it "should accept a description" do
	desc='test description'
	expense=Expense.create!(@attr.merge(:description =>desc))
	expense.reload
	# test
	expense.description.should == desc
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

    it "should user the proper rspec helper amount" do
	expense=Expense.new(@attr)
	# Test helper
	expense.amount.to_f.should == 10.50
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

    it "should return false if invalid user given to process method" do
	# Variables
	amount=22.00
	# Get today
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Create users
	u1=User.create!({:user_name => 'test90', :password => 'testpassword'})
	u2=User.create!({:user_name => 'test91', :password => 'testpassword'})
	# Create group
	group=Group.create!({:name => "Group test", :description => 'group 1 desc'})
	# Add user to group
	group.add_user(u1)
	group.add_user(u2)
	# Create expense
	expense=Expense.new(@attr)
	# Set group
	expense.group_id=group.id
	# Set amount
	expense.amount=amount
	# Save expense
	expense.save!
	# Test
	expense.process(999999).should == false
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
	    expense.process(u1.id)
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
	expense.affected_users.should == "#{u1.id},#{u2.id},#{u3.id}"
    end

    it "should not allow amount to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get amount
	amount=expense.amount
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.amount=amount + 10
	# Test: not valid
	expense.should_not be_valid
	# Test: should not save
	expense.save.should == false
	# Test: should have an error message
	expense.errors.size.should >  0
    end

    it "should not allow user_id to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new user
	new_user=User.create!(:user_name => 'test_expense', :password => 'abcd1234')
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.user_id=new_user.id
	# Test: not valid
	expense.should_not be_valid
	# Test: should not save
	expense.save.should == false
	# Test: should have an error message
	expense.errors.size.should >  0
    end

    it "should not allow group to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new Group
	new_group=Group.create!(:name => "Expense Group 1", :description => 'group 1 desc')
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.group_id=new_group.id
	# Test: not valid
	expense.should_not be_valid
	# Test: should not save
	expense.save.should == false
	# Test: should have an error message
	expense.errors.size.should >  0
    end

    it "should allow reason to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new Group
	new_reason=Reason.create!(:name => "expense_test")
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.reason_id=new_reason.id
	# Test:valid
	expense.should be_valid
	# Test: should save
	expense.save!
    end

    it "should allow pay_method to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new Group
	new_pay_method=PayMethod.create!(:name => "expense_test")
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.pay_method_id=new_pay_method.id
	# Test:valid
	expense.should be_valid
	# Test: should save
	expense.save!
    end

    it "should allow store to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new Group
	new_store=Store.create!(:name => "expense_test")
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Modify
	expense.store_id=new_store.id
	# Test:valid
	expense.should be_valid
	# Test: should save
	expense.save!
    end

    it "should allow description to be modified if it has been processed" do
	# Create expense
	expense=Expense.create!(@attr)
	# Get new Group
	new_desc=expense.description.to_s + 'aaaaaa'
	# Process record
	expense.process(expense.user_id)
	# Reload
	expense.reload
	# Test: not the same description
	expense.description.should_not == new_desc
	# Modify
	expense.description=new_desc
	# Test:valid
	expense.should be_valid
	# Test: should save
	expense.save!
    end

    it "should respond to user_depts" do
	# Create expense
	expense=Expense.create!(@attr)
	# Test
	expense.should respond_to(:user_depts)
    end

    it "should be able to get it's associated user_depts" do
	# Set amount
	amount=12.50
	# Create users
	u1=User.create!({:user_name => 'test90', :password => 'testpassword'})
	u2=User.create!({:user_name => 'test91', :password => 'testpassword'})
	# Create group
	group=Group.create!({:name => "Group test", :description => 'group 1 desc'})
	# Add user to group
	group.add_user(u1)
	group.add_user(u2)
	# Create expense
	expense=Expense.new(@attr)
	# Set amount
	expense.amount=amount
	# Set group
	expense.group_id=group.id
	# Save expense
	expense.save!
	# Test: UserDept created
	lambda{
	    # Process record
	    expense.process(expense.user_id)
	}.should change(UserDept,:count).by(2)
	# Reload expense
	expense.reload
	# Test
	expense.user_depts.size.should == 2
	# Test amount
	expense.user_depts.first.amount.should == amount / 2.0
    end

    it "should process floats correctly" do
	# Variables
	amount=22.11
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
	    expense.process(expense.user_id)
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

    it "should process integers correctly" do
	# Variables
	amount=5
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
	    expense.process(expense.user_id)
	}.should change(UserDept,:count).by(3)
	# Reload expense
	expense.reload
	# Test: Check UserDept
	users.each do |u|
	    # Get UserDept
	    ud=UserDept.where(:from_user_id => expense.user_id).where(:to_user_id => u.id).last
	    # Test
	    ud.amount.should == amount / users.size.to_f
	end
	# Test: UserBalance Created
	users.each do |u|
	    # Get UserDept
	    ub=UserBalance.where(:from_user_id => expense.user_id).where(:to_user_id => u.id).last
	    # Test
	    ub.amount.should == amount / users.size.to_f
	end
	# Test process fields
	expense.process_flag.should == true
	expense.process_date.strftime("%Y-%m-%d").should == today
    end

    pending "should pass the master check of update_balances" do
	# Add users
	# Add dept
	# Add payment
	# Update balances
	# Test
	# Add dept
	# Update balances
	# Test
	# Update balances
	# Test
	# Add payment
	# Update balances
	# Test
	# Add dept
	# Add payment
	# Update balances
	# Test
    end

    it "should require duplication_check_hash" do
	expense=Expense.new(@attr)
	# Save
	expense.save!
	# Get hash
	dup_hash=expense.duplication_check_hash
	# Test
	dup_hash.size.should > 0
	# Test, should be sha2
	dup_hash.size.should == 64
    end

    it "should use date_purchased, amount and store_id to create duplication_check_hash" do
	# Variables
	amount=43.69
	date_purchased=Date.today
	expense=Expense.new(@attr)
	# Set date_purchased
	expense.date_purchased=date_purchased
	# Set amount
	expense.amount=amount
	# Get store
	store_id=expense.store_id
	# Create hash_string
	hash_string=date_purchased.strftime('%Y-%m-%d').to_s + amount.to_s + store_id.to_s
	# Created expected hash
	expected_hash=Digest::SHA2.hexdigest(hash_string)
	# Save
	expense.save!
	# Get hash
	dup_hash=expense.duplication_check_hash
	# Test
	dup_hash.should == expected_hash
    end

    it "should not allow duplication_check_reviewed to be set on creation" do
	expense=Expense.new(@attr)
	# Set field
	expense.duplication_check_reviewed=true
	# Test
	expense.should_not be_valid
    end

    it "should allow duplication_check_reviewed to be set after creation" do
	expense=Expense.new(@attr)
	# Save
	expense.save!
	# Reload
	expense.reload
	# Set field
	expense.duplication_check_reviewed=true
	# Test
	expense.should be_valid
    end

    it "should have duplication_check_reviewed set to false on creation" do
	expense=Expense.new(@attr)
	# Save
	expense.save!
	# Test
	expense.duplication_check_reviewed.should == false
    end

    it "should respond to a find_duplicates class method" do
	# Test
	Expense.should respond_to(:find_duplicates)
    end

    it "should find duplicates if self.find_duplicates is called" do
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	e3=Expense.create!(@attr.merge(:date_purchased => Date.today, :user_id => u2.id))
	e4=Expense.create!(@attr.merge(:date_purchased => Date.today, :user_id => u2.id))
	e5=Expense.create!(@attr.merge(:date_purchased => Date.today, :user_id => u2.id))
	# Test
	Expense.find_duplicates(u1.id).size.should == 2
	Expense.find_duplicates(u2.id).size.should == 3
    end

    it "should respond to a find_duplicates method" do
	expense=Expense.new(@attr)
	# Test
	expense.should respond_to(:find_duplicates)
    end

    it "should be able to find a duplicate before record is saved" do
	# Create expense
	e1=Expense.create!(@attr)
	# Get user
	u_id=e1.user_id
	# Create new expense
	e2=Expense.new(@attr.merge(:user_id => u_id))
	# Test
	e2.find_duplicates.size.should > 0
    end

    it "should be able to find a duplicate after record is saved" do
	# Create expense
	e1=Expense.create!(@attr)
	# Get user
	u_id=e1.user_id
	# Create new expense
	e2=Expense.create!(@attr.merge(:user_id => u_id))
	# Reload
	e2.reload
	# Test
	e2.find_duplicates.size.should > 0
    end

    it "should be able to review possible duplicates" do
	# Create users
	u1=get_next_user
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	# Test class method
	Expense.find_duplicates(u1.id).size.should == 2
	# Test record method
	e1.find_duplicates.size.should > 0
	# Review this record and all duplicate records
	e1.review_duplicates
	# Test
	Expense.find_duplicates(u1.id).size.should == 0
	e1.find_duplicates.size.should == 0
    end

    it "should ignore duplicate records that have been reviewed" do
	# Create users
	u1=get_next_user
	# Get 2nd date
	date2=@attr[:date_purchased].tomorrow
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	e3=Expense.create!(@attr.merge(:date_purchased => date2, :user_id => u1.id))
	e4=Expense.create!(@attr.merge(:date_purchased => date2, :user_id => u1.id))
	e5=Expense.create!(@attr.merge(:date_purchased => date2, :user_id => u1.id))
	# Test
	Expense.find_duplicates(u1.id).size.should == 5
	e1.find_duplicates.size.should == 2
	e3.find_duplicates.size.should == 3
	# Review first set of duplicates
	e1.review_duplicates
	# Test
	Expense.find_duplicates(u1.id).size.should == 3
	e1.find_duplicates.size.should == 0
	e3.find_duplicates.size.should == 3
    end

    it "should have find_duplicates return nothing if it has no duplicates" do
	# Create expense
	e1=Expense.create!(@attr)
	# Get user
	u_id=e1.user_id
	# Test
	Expense.find_duplicates(u_id).size.should == 0
	e1.find_duplicates.size.should == 0
    end

    it "should set duplication_check_reviewed to false if a duplicate is created in the future" do
	# Create users
	u1=get_next_user
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	# Test class method
	Expense.find_duplicates(u1.id).size.should == 2
	e1.find_duplicates.size.should == 2
	# Review this record and all duplicate records
	e1.review_duplicates
	# Test
	e1.find_duplicates.size.should == 0
	Expense.find_duplicates(u1.id).size.should == 0
	# Create new record
	e3=Expense.create!(@attr.merge(:user_id => u1.id))
	# Test
	e1.find_duplicates.size.should == 3
	Expense.find_duplicates(u1.id).size.should == 3
    end

    it "should create a new record with duplication_check_processed set to false" do
	# Create expense
	expense=Expense.new(@attr)
	# Check flag
	expense.duplication_check_processed.should == false
	# Save record
	expense.save!
	expense.reload
	# Test
	expense.duplication_check_processed.should == false
    end

    it "should not allow duplication_check_processed to be set on creation" do
	# Create expense
	expense=Expense.new(@attr)
	# Set field
	expense.duplication_check_processed=true
	# Test
	expense.should_not be_valid
    end

    it "should set duplication reviewed date on review" do
	# Get today
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Create users
	u1=get_next_user
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	# Test class method
	Expense.find_duplicates(u1.id).size.should == 2
	# Test record method
	e1.find_duplicates.size.should > 0
	# Review this record and all duplicate records
	e1.review_duplicates
	# Test
	e1.reload.duplication_check_reviewed_date.strftime("%Y-%m-%d").should == today
	e2.reload.duplication_check_reviewed_date.strftime("%Y-%m-%d").should == today
    end

    it "should respond to note" do
	# Create expenses
	e1=Expense.create!(@attr)
	# Test
	e1.should respond_to(:expense_note)
    end

    it "could have a note for reviewed duplicates" do
	# Create users
	u1=get_next_user
	# Create expenses
	e1=Expense.create!(@attr.merge(:user_id => u1.id))
	e2=Expense.create!(@attr.merge(:user_id => u1.id))
	# Create note
	note=ExpenseNote.new({:note => 'aaa'})
	# Review record with note
	e1.review_duplicates(note)
	# Test
	e1.reload.expense_note.should == note
	e2.reload.expense_note.should == note
    end
end
