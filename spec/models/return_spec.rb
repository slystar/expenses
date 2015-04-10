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

    it "should be accessible through an expense object" do
	# Get object
	object=Return.create!(@attr)
	# Test
	object.expense.returns.size.should == 1
	# Add another return
	object2=Return.create!(@attr)
	# Test
	@exp.returns.size.should == 2
	@exp.returns.include?(object)
	@exp.returns.include?(object2)
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

    it "should link to UserPayments" do
	# Variables
	amount=10
	# Get user
	u1=get_next_user
	u2=get_next_user
	# Get user_payment
	up=add_user_payment(u1,u2,amount,true)
	# Get Object
	obj=Return.create!(@attr)
	# Link return (artifficially)
	up.return_id=obj.id
	# Save
	up.save.should == true
	# Tests
	u1.id.should_not == u2.id
	obj.user_payments.include?(up).should == true
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
	    object.user_payments.size.should == 1
	end

	it "process 3 users" do
	    # Variables
	    num_users=3
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
	    last_user.depts.last.amount.round(2).should == (prev_dept - (@return_amount / num_users)).round(2)
	    UserPayment.all.size.should == 2
	    UserPayment.first.amount.should == @return_amount / num_users
	    object.user_payments.size.should == 2
	end

	it ", master test" do
	    # Variables
	    dept1=3.33
	    dept2=5
	    dept3=11.43
	    dept4=2.22
	    payment1=4.44
	    payment2=20
	    payment3=2.33
	    # Add users
	    u1=User.find(@attr[:user_id])
	    u2=get_next_user
	    u3=get_next_user
	    # Create group
	    g_all=Group.create!(:name => Faker::Company.name, :description => 'Test group all')
	    # Add group members
	    g_all.users = [u1,u2,u3]
	    # Test groups
	    g_all.group_members.size.should == 3
	    # Create expense records
	    exp1=get_valid_expense({:amount => dept1, :user_id => u1.id, :group_id => g_all.id})
	    exp2=get_valid_expense({:amount => dept2, :user_id => u1.id, :group_id => g_all.id})
	    exp3=get_valid_expense({:amount => dept3, :user_id => u2.id, :group_id => g_all.id})
	    exp4=get_valid_expense({:amount => dept4, :user_id => u1.id, :group_id => u2.self_group.id})
	    # Get records to process
	    need_process=Expense.where(:process_flag => false)
	    # Test
	    need_process.size.should == 5
	    # Add dept
	    need_process.each{|e| e.process(e.user_id)}
	    # Test: depts
	    expected_dept_1_2=(dept3 / 3.0)
	    expected_dept_1_3=0
	    expected_dept_2_1=(dept1 / 3.0) + (dept2 / 3.0) + dept4
	    expected_dept_2_3=0
	    expected_dept_3_1=(dept1 / 3.0) + (dept2 / 3.0)
	    expected_dept_3_2=(dept3 / 3.0)
	    UserDept.all.size.should == 7
	    UserDept.where(:from_user_id => u1.id, :to_user_id => u2.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_1_2
	    UserDept.where(:from_user_id => u1.id, :to_user_id => u3.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_1_3
	    UserDept.where(:from_user_id => u2.id, :to_user_id => u1.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_2_1
	    UserDept.where(:from_user_id => u2.id, :to_user_id => u3.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_2_3
	    UserDept.where(:from_user_id => u3.id, :to_user_id => u1.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_3_1
	    UserDept.where(:from_user_id => u3.id, :to_user_id => u2.id).inject(0){|sum,ud| sum + ud.amount}.should == expected_dept_3_2
	    # Get last dept
	    last_dept=UserDept.last
	    # Test: balances
	    expected_balance_1_2=expected_dept_1_2 - expected_dept_2_1
	    expected_balance_1_3=expected_dept_1_3 - expected_dept_3_1
	    expected_balance_2_3=expected_dept_1_3 - expected_dept_3_2
	    test_balances(u1,u2,expected_balance_1_2)
	    test_balances(u1,u3,expected_balance_1_3)
	    test_balances(u2,u3,expected_balance_2_3)
	    # New return
	    return_object=Return.new(@attr.merge(:amount => dept2, :user_id => u1.id, :expense_id => exp2.id))
	    # Save return
	    return_object.save.should == true
	    # Process return
	    return_object.process(u1.id)
	    # Add payment
	    add_user_payment(u1,u2,payment1)
	    add_user_payment(u2,u1,payment2)
	    add_user_payment(u1,u2,payment3)
	    # Update balances
	    lambda {
		# Update balances
		UserBalance.update_balances(u1.id)
	    }.should change(UserBalance,:count).by(2)
	    # Get expected return amount
	    return_amount = dept2 / g_all.users.size.to_f
	    # Get expected balance
	    expected_balance_1_2=expected_balance_1_2 - payment1 - payment3 + payment2 + return_amount
	    expected_balance_1_3=expected_balance_1_3 + return_amount
	    # Test
	    test_balances(u1,u2,expected_balance_1_2)
	    test_balances(u1,u3,expected_balance_1_3)
	    test_balances(u2,u3,expected_balance_2_3)
	end

	it "if the return was saved previously" do
	    # Save expense
	    @exp.save.should == true
	    # Process expense
	    @exp.process(@exp.user_id)
	    # Get object
	    object=Return.new(@attr)
	    # Try to process
	    object.process(object.user_id).should == false
	    object.errors.size.should > 0
	    # Reset fields
	    object.process_date=nil
	    object.process_flag=false
	    # Save record
	    object.save.should == true
	    # Process again
	    object.process(object.user_id).should == true
	end

	it "if the expense has been processed" do
	    # Save expense
	    @exp.save.should == true
	    # Test expense object
	    @exp.process_flag.should == false
	    # Get object
	    object=Return.new(@attr)
	    # Save object
	    object.save.should == true
	    # Test
	    object.process(@exp.user_id).should == false
	    object.errors.size.should > 0
	    object.expense.should == @exp
	    # Process expense
	    @exp.process(@exp.user_id).should == true
	    # Reload
	    object.reload
	    # Test
	    object.process(@exp.user_id).should == true
	end
    end
end
