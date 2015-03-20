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

    pending "should return the correct amount to each person" do
    end
end
