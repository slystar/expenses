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

    def add_user_dept(u1,u2,amount)
	# Create new UserDept
	ud=UserDept.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=u2.id
	ud.amount=amount
	# Save UserDept
	ud.save!
    end

    def add_user_payment(u1,u2,amount)
	# Create new UserPayment
	ud=UserPayment.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=u2.id
	ud.amount=amount
	# Save UserDept
	ud.save!
	# Approve payment
	ud.approve
    end

    def get_next_user()
	# Get next user id
	@new_user_id += 1
	# Create user object
	u=User.create!(:user_name => "user#{@new_user_id}", :password => 'testpassuserbalance')
	# Return user object
	return u
    end

    def add_balance(u1,u2,amount)
	# Get a UserBalance object
	ub=UserBalance.new()
	# Set attributes
	ub.from_user_id=u1.id
	ub.to_user_id=u2.id
	ub.amount=amount
	# Save UserBalance
	ub.save!
    end

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
		# Get expected balance
		expected_balance=money + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money)
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
		# Get expected balance
		expected_balance=money1 + money2 + money3 + existing_balance
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1)
		add_user_dept(u1,u2,money2)
		add_user_dept(u1,u2,money3)
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
		# Get expected balance
		expected_balance=(money1 + money2 + existing_balance) - money3
		# Create users
		u1=get_next_user
		u2=get_next_user
		# Create new UserDept
		add_user_dept(u1,u2,money1)
		add_user_dept(u1,u2,money2)
		add_user_dept(u2,u1,money3)
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
	    it "with single credit" do
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

	    it "with multiple credit for a single user" do
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

	    it "with multiple credit for multiple users" do
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
	    pending 'need tests'
	end

	context "with userDept, UserPayment and UserBalance" do
	    pending 'need tests'
	end
    end
end
