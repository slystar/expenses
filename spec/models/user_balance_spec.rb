require 'spec_helper'

describe UserBalance do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
	@new_user_id=1
    end

    def get_new_user_balance
	# Create user
	u1=get_next_user
	u2=get_next_user
	# No methods are mass assignable
	ub=UserBalance.new()
	# Add attributes
	ub.from_user_id=u1.id
	ub.to_user_id=u2.id
	ub.amount=@attr[:amount]
	# Return object
	return ub
    end

    # Test balance
    def test_balance(u1,u2,amount)
	    # Get most recent UserBalance for u1 to u2
	    ub=UserBalance.where(:from_user_id => u1.id, :to_user_id => u2.id).last
	    # Test: UserBalance amount
	    ub.amount.should == amount
    end

    it "should create a new instance given valid attributes" do
	# get object
	ub=get_new_user_balance
	# Save object
	ub.save.should == true
    end

    it "should create a new instance with previous_user_balance_id = 0" do
	# get object
	ub=get_new_user_balance
	# Save object
	ub.save.should == true
	# Test: column
	ub.previous_user_balance_id.should == 0
    end

    it "should not allow previous_user_balance_id to be set on creation" do
	# get object
	ub=get_new_user_balance
	# Set column
	ub.previous_user_balance_id=1
	# Test
	ub.should_not be_valid
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

    it "should have an 'update_balances' method" do
	UserBalance.should respond_to(:update_balances)
    end

    describe "update balances" do
	context "with UserDept and UserBalance" do
	    it "with single dept" do
		# Set amount
		money=12.50
		existing_balance=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		# 12.50(new dept) + 5.25(existing dept)
		expected_balance=money + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money,expense.id)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple dept for a single user" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		existing_balance=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		# existing dept + existing balance
		expected_balance=money1 + money2 + money3 + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1,expense.id)
		add_user_dept(u1,u2,money2,expense.id)
		add_user_dept(u1,u2,money3,expense.id)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple dept for multiple users" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		existing_balance=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=(money1 + money2 + existing_balance) - money3
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1,expense.id)
		add_user_dept(u1,u2,money2,expense.id)
		add_user_dept(u2,u1,money3,expense.id)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end
	end

	context "with UsePayment and UserBalance" do
	    it "with single payment" do
		# Set amount
		money=12.50
		existing_balance=5.25
		# Get expected balance
		expected_balance=existing_balance - money
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserPayment
		add_user_payment(u1,u2,money)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple payment for a single user" do
		# Set amount
		money1=BigDecimal('2.50')
		money2=BigDecimal('1.20')
		money3=BigDecimal('0.40')
		existing_balance=5.25
		# Get expected balance
		expected_balance=existing_balance - (money1 + money2 + money3)
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserPayment
		add_user_payment(u1,u2,money1)
		add_user_payment(u1,u2,money2)
		add_user_payment(u1,u2,money3)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple payment for multiple users" do
		# Set amount
		money1=BigDecimal('2.50')
		money2=BigDecimal('1.20')
		money3=BigDecimal('0.40')
		existing_balance=BigDecimal('5.25')
		# Get expected balance
		expected_balance=(existing_balance + money2) - (money1 + money3)
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserPayment
		add_user_payment(u1,u2,money1)
		add_user_payment(u2,u1,money2)
		add_user_payment(u1,u2,money3)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end
	end

	context "with UserDept, UserPayment" do
	    it "with single dept" do
		# Set amount
		money=12.50
		payment=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=money - payment
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple dept for a single user" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		payment=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=money1 + money2 + money3 - payment
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1,expense.id)
		add_user_dept(u1,u2,money2,expense.id)
		add_user_dept(u1,u2,money3,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple dept for multiple users" do
		# Set amount
		money1=12.50
		money2=30.20
		money3=2.00
		payment=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=(money1 + money2 - payment) - money3
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1,expense.id)
		add_user_dept(u1,u2,money2,expense.id)
		add_user_dept(u2,u1,money3,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end
	end

	context "with userDept, UserPayment and UserBalance" do
	    it "with single dept and single payment" do
		# Set amount
		dept1=12.50
		payment1=7.30
		existing_balance=5.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=dept1 - payment1 + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,dept1,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment1)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
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
		# Get an expense record
		expense=get_valid_expense
		# Get expected balance
		expected_balance=(dept1 + dept2 + dept3) - (payment1 + payment2 + payment3) + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,dept1,expense.id)
		add_user_dept(u1,u2,dept2,expense.id)
		add_user_dept(u1,u2,dept3,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment1)
		add_user_payment(u1,u2,payment2)
		add_user_payment(u1,u2,payment3)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple payment for multiple users" do
		# Set amount
		dept1=12.50
		dept2=14.50
		dept3=1634.50
		payment1=3.30
		payment2=1.30
		payment3=220.95
		existing_balance1=5.25
		existing_balance2=500.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balances
		u1_balance=(dept1 + dept2) - (payment1 + payment3) + existing_balance1
		u2_balance=(dept3) - (payment2) + existing_balance2
		expected_balance=u1_balance - u2_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,dept1,expense.id)
		add_user_dept(u1,u2,dept2,expense.id)
		add_user_dept(u2,u1,dept3,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment1)
		add_user_payment(u2,u1,payment2)
		add_user_payment(u1,u2,payment3)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance1)
		add_balance(u2,u1,existing_balance2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end

	    it "with multiple balances for multiple users" do
		# Set amount
		dept1=12.50
		dept2=14.50
		dept3=1634.50
		payment1=3.30
		payment2=1.30
		payment3=220.95
		existing_balance1_1=15.25
		existing_balance1_2=5.25
		existing_balance1_3=35.25
		existing_balance2=500.25
		# Get an expense record
		expense=get_valid_expense
		# Get expected balances
		u1_balance=(dept1 + dept2) - (payment1 + payment3) + existing_balance1_3
		u2_balance=(dept3) - (payment2) + existing_balance2
		expected_balance=u1_balance - u2_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,dept1,expense.id)
		add_user_dept(u1,u2,dept2,expense.id)
		add_user_dept(u2,u1,dept3,expense.id)
		# Create new UserPayment
		add_user_payment(u1,u2,payment1)
		add_user_payment(u2,u1,payment2)
		add_user_payment(u1,u2,payment3)
		# Create new UserBalance
		add_balance(u1,u2,existing_balance1_1)
		add_balance(u1,u2,existing_balance1_2)
		add_balance(u1,u2,existing_balance1_3)
		add_balance(u2,u1,existing_balance2)
		# Test: UserBalance created
		lambda {
		    # Update balances
		    UserBalance.update_balances
		}.should change(UserBalance,:count).by(2)
		# Test balances
		test_balance(u1,u2,expected_balance)
		test_balance(u2,u1,-(expected_balance))
	    end
	end
    end

    it "should set the previous_user_balance_id when processing" do
	# Set amount
	money=12.50
	existing_balance1_1=15.25
	existing_balance1_2=5.25
	existing_balance1_3=35.25
	existing_balance2=8.25
	# Get an expense record
	expense=get_valid_expense
	# Get expected balance
	expected_balance=money + existing_balance1_3 - existing_balance2
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Create new UserDept
	add_user_dept(u1,u2,money,expense.id)
	# Create new UserBalance
	ub1=add_balance(u1,u2,existing_balance1_1)
	ub2=add_balance(u1,u2,existing_balance1_2)
	ub3=add_balance(u1,u2,existing_balance1_3)
	ub4=add_balance(u2,u1,existing_balance2)
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances
	}.should change(UserBalance,:count).by(2)
	# Test balances
	test_balance(u1,u2,expected_balance)
	test_balance(u2,u1,-(expected_balance))
	# Check previous balance
	ub1.previous_user_balance_id.should == 0
	UserBalance.where(:from_user_id => u1, :to_user_id => u2).last.previous_user_balance_id.should == ub3.id
	UserBalance.where(:from_user_id => u2, :to_user_id => u1).last.previous_user_balance_id.should == ub4.id
    end
end
