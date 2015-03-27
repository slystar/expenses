require 'spec_helper'

describe Return do
    before(:each) do
	@exp=get_valid_expense
	@attr={:description => Faker::Company.name, :expense_id => @exp.id, :transaction_date => Date.today, :user_id => @exp.user_id, :amount => @exp.amount - 1}
    end

    it "should create a new instance given valid attributes" do
	Return.create!(@attr)
    end

    it "should require 'expense_id'" do
	# Get object
	object=Return.new(@attr.merge(:expense_id => nil))
	# Test
	object.should_not be_valid
    end

    it "should require 'amount'" do
	# Get object
	object=Return.new(@attr.merge(:amount => nil))
	# Test
	object.should_not be_valid
    end

    it "should not require 'description'" do
	# Get object
	object=Return.new(@attr.merge(:description => nil))
	# Test
	object.should be_valid
    end

    it "should require 'user_id'" do
	# Get object
	object=Return.new(@attr.merge(:user_id => nil))
	# Test
	object.should_not be_valid
    end

    it "should require 'transaction_date'" do
	# Get object
	object=Return.new(@attr.merge(:transaction_date => nil))
	# Test
	object.should_not be_valid
    end

    it "should require 'created_at" do
	# Get object
	object=Return.create!(@attr)
	# Test
	object.created_at.should_not be_nil
    end

    it "should require 'updated_at" do
	# Get object
	object=Return.create!(@attr)
	# Test
	object.updated_at.should_not be_nil
    end

    it "should have a default app_version" do
	object=Return.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=Return.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a valid expense" do
	# Get object
	object=Return.new(@attr)
	# Set expense_id
	object.expense_id=99999
	# Test
	object.should_not be_valid
    end

    it "should require a valid user" do
	# Get object
	object=Return.new(@attr)
	# Set expense_id
	object.user_id=99999
	# Test
	object.should_not be_valid
    end

    it "should use the proper rspec helper amount" do
	object=Return.new(@attr)
	# Test helper
	object.amount.to_f.should == 9.50
    end

    it "should allow a single decimal in amount" do
	object=Return.new(@attr)
	object.amount="1.5"
	object.should be_valid
    end

    it "should not allow more than 2 decimal places in amount" do
	object=Return.new(@attr)
	object.amount="1.567"
	object.should_not be_valid
    end

    it "should not accept negative amounts" do
	object=Return.new(@attr)
	object.amount="-1.567"
	object.should_not be_valid
    end

    it "should not allow letters in amount" do
	object=Return.new(@attr)
	object.amount="aa15"
	object.should_not be_valid
    end

    it "should make sure amount is not greater than target expense" do
	# Get object
	object=Return.new(@attr)
	# Set expense_id
	object.amount=@exp.amount + 0.01
	# Test
	object.should_not be_valid
    end

    it "should allow a return amount equal to expense amount" do
	# Get object
	object=Return.new(@attr)
	# Set expense_id
	object.amount=@exp.amount
	# Test
	object.should be_valid
    end

    it "should not have a transaction date before the expense purchase date" do
	# Get object
	object=Return.new(@attr)
	# Set transaction_date
	object.transaction_date=@exp.date_purchased.yesterday
	# Test
	object.should_not be_valid
    end

    it "should allow a transaction date on or after the expense purchase date" do
	# Get object
	object=Return.new(@attr)
	# Set transaction_date to equal
	object.transaction_date=@exp.date_purchased
	# Test
	object.should be_valid
	# Set transaction_date to after
	object.transaction_date=@exp.date_purchased + 1
	# Test
	object.should be_valid
    end

    it "should be able to pull expense information" do
	# Get object
	object=Return.create!(@attr)
	# Test
	object.expense.store.should == @exp.store
    end

    it "should not be created with a process date" do
	object=Return.new(@attr)
	object.process_date=Time.now
	object.should_not be_valid
    end

    it "should allow a process date once it's been saved" do
	object=Return.create!(@attr)
	object.process_date=Time.now
	object.should be_valid
    end

    it "should not be created with process flag set to true" do
	object=Return.new(@attr)
	object.process_flag=true
	object.should_not be_valid
    end

    it "should allow to set process_flag once it's been saved" do
	object=Return.create!(@attr)
	object.process_flag=true
	object.should be_valid
    end

    it "should not be destroyable if it's been processed" do
	object=Return.create!(@attr)
	object.process_flag=true
	object.destroy
	object.should_not be_destroyed
    end

    it "should be destroyable if it has not been processed" do
	object=Return.create!(@attr)
	object.destroy
	object.should be_destroyed
    end

    it "should be modifyable if it has not been processed" do
	# Create object
	object=Return.create!(@attr)
	# Modify
	object.amount=object.amount - 1
	# Should save
	object.save.should == true
    end

    it "should respond to a 'process' method" do
	# Create object
	object=Return.create!(@attr)
	# Test
	object.should respond_to(:process)
    end

    it "should return false if invalid user given to process method" do
	# Get object
	object=Return.new(@attr)
	# Save object
	object.save.should == true
	# Test
	object.process(999999).should == false
    end

    pending "should link to UserPayments" do
    end

    describe "should return the correct amount to each person" do
	before(:each) do
	    @exp_amount=22.00
	    @return_amount=5.00
	end

	# Method to create an expense and process with users
	def create_expense_and_process(user_count)
	    # Variables
	    attr_exp=get_attr_expense
	    counter=91
	    users=[]
	    # Get today
	    today=Time.now.utc.strftime("%Y-%m-%d")
	    # Create users
	    user_count.times do |x|
		users.push(User.create!({:user_name => "test#{counter}", :password => 'testpassword'}))
		counter += 1
	    end
	    # Create group
	    group=Group.create!({:name => "Group test", :description => 'group 1 desc'})
	    # Loop over users
	    users.each do |u|
		# Add user to group
		group.add_user(u)
	    end
	    # Create expense
	    expense=Expense.new(attr_exp)
	    # Set group
	    expense.group_id=group.id
	    # Set user
	    expense.user_id=users.first.id
	    # Set amount
	    expense.amount=@exp_amount
	    # Save expense
	    expense.save!
	    # Test: UserDept created
	    lambda{
		# Process record
		expense.process(users.first.id)
	    }.should change(UserDept,:count).by(user_count - 1)
	    # Test depts
	    users[1..-1].each do |u|
		u.depts.first.amount.should == @exp_amount / user_count
	    end
	    # Test
	    group.users.size.should == user_count
	    # Return expense
	    return [expense,group]
	end

	it "process 2 users" do
	    # Variables
	    num_users=2
	    # Get expense
	    expense,group=create_expense_and_process(num_users)
	    # Test: make sure we have more than one user
	    expense.affected_users.split(',').size.should == num_users
	    # Get last user
	    last_user=group.users.last
	    prev_dept=last_user.depts.last.amount
	    # Create return
	    object=Return.new(@attr.merge(:expense_id => expense.id, :user_id => expense.user_id, :amount => @return_amount))
	    # Save return
	    object.save.should == true
	    # Process return
	    object.process(object.user_id)
	    # Reload
	    object.reload
	    # Test
	    last_user.depts.last.amount.should == prev_dept - (@return_amount / num_users)
	    UserPayment.all.size.should == 1
	    UserPayment.first.amount.should == @return_amount / num_users
	end
    end
end
