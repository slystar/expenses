require 'spec_helper'

describe UserBalance do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    def get_new_user_balance
	# Create user
	u1=User.create!(:user_name => 'user1', :password => 'testpassworduserbalance')
	u2=User.create!(:user_name => 'user2', :password => 'testpassworduserbalance')
	# No methods are mass assignable
	ub=UserBalance.new()
	# Add attributes
	ub.from_user_id=u1.id
	ub.to_user_id=u2.id
	ub.amount=@attr[:amount]
	# Return object
	return ub
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

    it "should not accept negative amounts" do
	# get object
	ub=get_new_user_balance
	# Set amount
	ub.amount="-10.5"
	# Test
	ub.should_not be_valid
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
end
