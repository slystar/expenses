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

    pending "should require a valid expense" do
    end

    pending "should require a valid user" do
    end

    pending "should make sure amount is not greater than target expense" do
    end
end
