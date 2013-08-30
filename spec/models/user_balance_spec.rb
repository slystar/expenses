require 'spec_helper'

describe UserBalance do

    before(:each) do
	# Set variable for user ids
	@new_user_id=1
	# Create users
	@u1=get_next_user
	@u2=get_next_user
	# Create
	@attr={:from_user_id => @u1.id, :to_user_id => @u2.id, :amount => 11.23}
    end

    def get_new_user_balance(attr=@attr)
	# No methods are mass assignable
	ub=UserBalance.new()
	# Add attributes
	ub.from_user_id=attr[:from_user_id]
	ub.to_user_id=attr[:to_user_id]
	ub.amount=attr[:amount]
	# Return object
	return ub
    end

    # Test balance
    def test_balances(u1,u2,amount)
	    # Get most recent UserBalance for u1 to u2
	    ub=UserBalance.where(:from_user_id => u1.id, :to_user_id => u2.id).last
	    # Test: UserBalance amount
	    ub.amount.should == amount
	    # Get most recent UserBalance for u2 to u1
	    ub=UserBalance.where(:from_user_id => u2.id, :to_user_id => u1.id).last
	    # Test: UserBalance amount should be inverse
	    ub.amount.should == (amount * -1)
	    # UserPayments should all be set to processed
	    UserPayment.all.each do |up|
		up.process_flag.should == true
	    end
	    # userDepts should all be set to processed
	    UserDept.all.each do |ud|
		ud.process_flag.should == true
	    end
    end

    it "should create a new instance given valid attributes" do
	# get object
	ub=get_new_user_balance
	# Save object
	ub.save.should == true
    end

    it "should have a default app_version" do
	object=get_new_user_balance
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_new_user_balance
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a valid from_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	ub1=UserBalance.new(@attr.merge(:from_user_id => nil))
	ub2=UserBalance.new(@attr.merge(:from_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	ub1.should_not be_valid
	# Should require a valid user
	ub2.should_not be_valid
    end

    it "should require a valid to_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	ub1=UserBalance.new(@attr.merge(:to_user_id => nil))
	ub2=UserBalance.new(@attr.merge(:to_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	ub1.should_not be_valid
	# Should require a valid user
	ub2.should_not be_valid
    end

    it "should not have the same from_user and to_user" do
	# get object
	ub=get_new_user_balance
	# Set to_user
	ub.to_user_id=ub.from_user_id
	# Test
	ub.should_not be_valid
    end

    it "should require an amount" do
	# get object
	ub=get_new_user_balance
	# Set amount to nil
	ub.amount=nil
	# Test
	ub.should_not be_valid
    end

    it "should accept more than 2 decimal places in amount" do
	# get object
	ub=get_new_user_balance
	# Set amount
	ub.amount=11.12345
	# Test
	ub.should be_valid
    end

    it "should accept negative amounts" do
	# get object
	ub=get_new_user_balance
	# Set amount
	ub.amount="-10.5"
	# Test
	ub.should be_valid
    end

    it "should not accept letters for amount" do
	# get object
	ub=get_new_user_balance
	# Set amount
	ub.amount="1abc"
	# Test
	ub.should_not be_valid
    end

    it "should not allow mass asignment" do
	# Create Object with mass assignment
	ub1=UserBalance.new(@attr)
	# Try to save
	ub1.save.should == false
    end

    it "should have an entry date" do
	# Get today's date
	today=Time.now.utc.strftime("%Y-%m-%d")
	# get object
	ub=get_new_user_balance
	# Save object
	ub.save!
	# Could be created date
	d1=ub.created_at.strftime("%Y-%m-%d")
	# Test
	today.should == d1
    end

    it "should not allow any field except revers_balance_id to be modified" do
	# Create object
	ub=get_new_user_balance
	# Sae 
	ub.save!
	# Reload
	ub.reload
	# Change amount
	ub.amount=ub.amount + 10
	# Try to save
	ub.save.should == false
    end

    it "should create reverse balance on create" do
	# Test
	UserBalance.all.size.should == 0
	# Create object
	get_new_user_balance.save!
	# Test
	UserBalance.all.size.should == 2
	# Get records
	ub1=UserBalance.first
	ub2=UserBalance.last
	# Test: should be opposite balance
	ub1.amount.should == (ub2.amount * -1)
    end

    it "should mark current balances on create" do
	# Get record
	ub1=get_new_user_balance
	# Save
	ub1.save!
	# Test
	ub1.current.should == true
	# Get 2nd record
	ub2=get_new_user_balance
	# Set new amount
	ub2.amount = ub1.amount + 10
	# Save
	ub2.save!
	# Reload
	ub1.reload
	ub2.reload
	# Test
	ub2.should_not == ub1
	ub2.current.should == true
	ub1.current.should == false
    end

    it "should not create a new balance if existing balance has same amount" do
	# Create object
	ub=get_new_user_balance
	# Save
	ub.save!
	# Test:
	UserBalance.all.size.should == 2
	# Add same balance
	ub2=get_new_user_balance
	# Save
	ub2.save.should == false
	# Test:
	UserBalance.all.size.should == 2
	# Add different balance
	ub=get_new_user_balance
	# Change amount
	ub.amount=ub.amount + 10
	# Save
	ub.save!
	# Test:
	UserBalance.all.size.should == 4
    end

    it "should have an 'update_balances' method" do
	UserBalance.should respond_to(:update_balances)
    end

    describe "'update_balances'" do

	it "should return true on success" do
	    # Create a dept
	    add_user_dept(@u1,@u2,10)
	    # Balance should be empty
	    UserBalance.all.size.should == 0
	    # Process
	    UserBalance.update_balances(@u1.id).should == true
	    # Should have 2 records u1->u2 and u2->u1
	    UserBalance.all.size.should == 2
	end

	it "should return false on invalid user" do
	    UserBalance.update_balances(99999999).should == false
	end

	def add_dept_and_test(u1,u2,amount,expected_balance)
	    # Create new UserDept (from: u1, to: u2)
	    add_user_dept(u1,u2,amount)
	    # Test: UserBalance created
	    lambda {
		# Update balances
		UserBalance.update_balances(u1.id)
	    }.should change(UserBalance,:count).by(2)
	    # Test balances (u1 owes u2)
	    test_balances(u1,u2,expected_balance)
	end

	context "with UserDept" do
	    it "and with single dept" do
		# Set amount
		money=12.50
		# Get expected balance
		expected_balance=money
		# Add dept and test
		add_dept_and_test(@u1,@u2,money, expected_balance)
		# Get expected balance
		expected_balance=money * 2
		# Add dept and test
		add_dept_and_test(@u1,@u2,money, expected_balance)
		expected_balance=money * 3
		# Add dept and test
		add_dept_and_test(@u1,@u2,money, expected_balance)
		# Extra tests
		UserDept.all.size.should == 3
		UserBalance.all.size.should == 6
		UserBalance.last.amount.to_f.abs.should == expected_balance
	    end
	end

	context "with UserDept and UserBalance" do
	    it "with single dept" do
		# Set amount
		money=12.50
		money2=2.11
		existing_balance=5.25
		# Get expected balance
		# 12.50(new dept) + 5.25(existing dept)
		expected_balance=money + existing_balance
		# Create new UserDept
		add_user_dept(@u1,@u2,money)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# Get expected balance
		# 12.50(new dept) + 5.25(existing dept)
		expected_balance2=expected_balance + (money + money2)
		# Create new UserDept
		add_user_dept(@u1,@u2,money)
		add_user_dept(@u1,@u2,money2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balances(@u1,@u2,expected_balance2)
		# Add 3rd round test
		expected_balance3=expected_balance2 + money + existing_balance
		# Create new UserDept
		add_user_dept(@u1,@u2,money)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance + expected_balance2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balances(@u1,@u2,expected_balance3)
	    end

	    it "with multiple dept for a single user" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		existing_balance=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u1,@u2,money3)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		# existing dept + existing balance
		expected_balance=money1 + money2 + money3 + existing_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u1,@u2,money3)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		# existing dept + existing balance
		expected_balance=(money1 + money2 + money3) * 2 + existing_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple dept for multiple users" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		existing_balance=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u2,@u1,money3)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		# existing dept + existing balance
		expected_balance=(money1 + money2 + existing_balance) - money3
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u2,@u1,money1)
		add_user_dept(@u1,@u2,money2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		# existing dept + existing balance
		expected_balance=expected_balance + money2 - money1
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end
	end

	context "with UsePayment and UserBalance" do
	    it "with single payment" do
		# Set amount
		money=12.50
		existing_balance=35.25
		# Create new UserPayment
		add_user_payment(@u1,@u2,money)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=existing_balance - money
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserPayment
		add_user_payment(@u1,@u2,money)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance - money
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple payment for a single user" do
		# Set amount
		money1=BigDecimal('2.50')
		money2=BigDecimal('1.20')
		money3=BigDecimal('0.40')
		existing_balance=5.25
		# Create new UserPayment
		add_user_payment(@u1,@u2,money1)
		add_user_payment(@u1,@u2,money2)
		add_user_payment(@u1,@u2,money3)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=existing_balance - (money1 + money2 + money3)
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserPayment
		add_user_payment(@u1,@u2,money1)
		add_user_payment(@u1,@u2,money2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance - (money1 + money2)
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple payment for multiple users" do
		# Set amount
		money1=BigDecimal('2.50')
		money2=BigDecimal('1.20')
		money3=BigDecimal('0.40')
		existing_balance=BigDecimal('5.25')
		# Create new UserPayment
		add_user_payment(@u1,@u2,money1)
		add_user_payment(@u2,@u1,money2)
		add_user_payment(@u1,@u2,money3)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=(existing_balance + money2) - (money1 + money3)
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserPayment
		add_user_payment(@u1,@u2,money1)
		add_user_payment(@u2,@u1,money2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance - money1 + money2
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end
	end

	context "with UserDept, UserPayment" do
	    it "with single dept" do
		# Set amount
		money1=12.50
		payment1=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=money1 - payment1
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance + (money1 - payment1)
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple dept for a single user" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		payment1=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u1,@u2,money3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=money1 + money2 + money3 - payment1
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u1,@u2,money3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance + money1 + money2 + money3 - payment1
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple dept for multiple users" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		payment1=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u2,@u1,money3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=(money1 + money2 - payment1) - money3
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,money1)
		add_user_dept(@u1,@u2,money2)
		add_user_dept(@u2,@u1,money3)
		# Create new UserPayment
		add_user_payment(@u2,@u1,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=expected_balance + money1 + money2 - money3 + payment1
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end
	end

	context "with userDept, UserPayment and UserBalance" do
	    it "with single dept and single payment" do
		# Set amount
		dept1=12.50
		payment1=7.30
		existing_balance=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=dept1 - payment1 + existing_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=dept1 - payment1 + expected_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple dept and multiple payment for a single user" do
		# Set amount
		dept1=12.50
		dept2=14.50
		dept3=1634.50
		payment1=3.30
		payment2=1.30
		payment3=0.95
		existing_balance=5.25
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		add_user_dept(@u1,@u2,dept2)
		add_user_dept(@u1,@u2,dept3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		add_user_payment(@u1,@u2,payment2)
		add_user_payment(@u1,@u2,payment3)
		# Create new UserBalance
		add_balance(@u1,@u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=(dept1 + dept2 + dept3) - (payment1 + payment2 + payment3) + existing_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		add_user_dept(@u1,@u2,dept2)
		add_user_dept(@u1,@u2,dept3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		add_user_payment(@u1,@u2,payment2)
		add_user_payment(@u1,@u2,payment3)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=(dept1 + dept2 + dept3) - (payment1 + payment2 + payment3) + expected_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end

	    it "with multiple payment for multiple users" do
		# Set amount
		dept1=12.50
		dept2=14.50
		dept3=1634.50
		payment1=3.30
		payment2=1.30
		payment3=220.95
		existing_balance=500.25
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		add_user_dept(@u1,@u2,dept2)
		add_user_dept(@u2,@u1,dept3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		add_user_payment(@u2,@u1,payment2)
		add_user_payment(@u1,@u2,payment3)
		# Create new UserBalance
		add_balance(@u2,@u1,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=dept1 + dept2 - dept3 - payment1 + payment2 - payment3 - existing_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# 2nd round
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		add_user_dept(@u1,@u2,dept2)
		add_user_dept(@u2,@u1,dept3)
		# Create new UserPayment
		add_user_payment(@u1,@u2,payment1)
		add_user_payment(@u2,@u1,payment2)
		add_user_payment(@u1,@u2,payment3)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=dept1 + dept2 - dept3 - payment1 + payment2 - payment3 + expected_balance
		# Test balances
		test_balances(@u1,@u2,expected_balance)
	    end
	end

	it "double process should not create new balances" do
	    # Set amount
	    dept1=12.50
	    existing_balance=15.25
	    # Create new UserDept
	    add_user_dept(@u1,@u2,dept1)
	    # Create new UserBalance
	    add_balance(@u2,@u1,existing_balance)
	    # Test: UserBalance created
	    lambda {
		# Update balances
		UserBalance.update_balances(@u1.id)
	    }.should change(UserBalance,:count).by(2)
	    # Get expected balance
	    expected_balance=dept1 - existing_balance
	    # Test balances
	    test_balances(@u1,@u2,expected_balance)
	    # Test: UserBalance created
	    lambda {
		# Update balances
		UserBalance.update_balances(@u1.id)
	    }.should change(UserBalance,:count).by(0)
	end
    end

    context "current column" do
	it "should be true on creation with all oters false" do
	    # get object
	    ub=get_new_user_balance
	    # Save object
	    ub.save!
	    # Test: column
	    ub.current.should == true
	    # get object
	    ub2=get_new_user_balance
	    # Set new amount
	    ub2.amount=ub.amount + 10
	    # Save object
	    ub2.save!
	    # Test: column
	    ub2.current.should == true
	    # Reload
	    ub.reload
	    # Test: column
	    ub.current.should == false
	end

	context "update_balances" do
	    it "should mark recent balances as current" do
		# Set amount
		dept1=12.50
		existing_balance1_1=15.25
		existing_balance1_2=5.25
		existing_balance1_3=35.25
		existing_balance2=8.25
		# Create new UserDept
		add_user_dept(@u1,@u2,dept1)
		# Create new UserBalance
		add_balance(@u2,@u1,existing_balance1_1)
		add_balance(@u2,@u1,existing_balance1_2)
		add_balance(@u2,@u1,existing_balance1_3)
		add_balance(@u2,@u1,existing_balance2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances(@u1.id)
		}.should change(UserBalance,:count).by(2)
		# Get expected balance
		expected_balance=dept1 - existing_balance2
		# Test balances
		test_balances(@u1,@u2,expected_balance)
		# Test: current records
		UserBalance.where(:current => true).size.should == 2
		UserBalance.where(:current => false).size.should == 8
	    end
	end
    end

    it "should link to UpdateBalanceHistory" do
	# Set amount
	dept1=12.50
	existing_balance=5.25
	# Create new UserDept
	add_user_dept(@u1,@u2,dept1)
	# Create new UserBalance
	add_balance(@u1,@u2,existing_balance)
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(@u1.id)
	}.should change(UserBalance,:count).by(2)
	# Get expected balance
	expected_balance=dept1 + existing_balance
	# Test balances
	test_balances(@u1,@u2,expected_balance)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Test
	UserBalance.all[-2,2].each do |ub|
	    ub.update_balance_history.should == ubh
	end
    end

    it "should have the method save_non_duplicates" do
	# get object
	ub=get_new_user_balance
	# Save should return true
	ub.save.should == true
	# Get object with same attributes
	ub2=get_new_user_balance
	# Saving should return false because there is a duplicate balance that is valid
	ub2.save.should == false
	# Saving with save_non_duplicates should return true because that balance is currently valid
	ub2.save_non_duplicates.should == true
	# There should only be 1 balance (2 records)
	UserBalance.all.size.should == 2
    end
end
