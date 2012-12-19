require 'spec_helper'

describe UserDept do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    def get_new_user_dept
	# Create user
	u1=User.create!(:user_name => 'user1', :password => 'testpassworduserdept')
	u2=User.create!(:user_name => 'user2', :password => 'testpassworduserdept')
	# No methods are mass assignable
	ud=UserDept.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=u2.id
	ud.amount=@attr[:amount]
	# Return object
	return ud
    end

    it "should create a new instance given valid attributes" do
	# get object
	ud=get_new_user_dept
	# Save object
	ud.save.should == true
    end

    it "should require a valid from_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	ud1=UserDept.new(@attr.merge(:from_user_id => nil))
	ud2=UserDept.new(@attr.merge(:from_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	ud1.should_not be_valid
	# Should require a valid user
	ud2.should_not be_valid
    end

    it "should require a valid to_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	ud1=UserDept.new(@attr.merge(:to_user_id => nil))
	ud2=UserDept.new(@attr.merge(:to_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	ud1.should_not be_valid
	# Should require a valid user
	ud2.should_not be_valid
    end

    it "should not have the same from_user and to_user" do
	# get object
	ud=get_new_user_dept
	# Set to_user
	ud.to_user_id=ud.from_user_id
	# Test
	ud.should_not be_valid
    end

    it "should require an amount" do
	# get object
	ud=get_new_user_dept
	# Set amount to nil
	ud.amount=nil
	# Test
	ud.should_not be_valid
    end

    it "should accept more than 2 decimal places in amount" do
	# get object
	ud=get_new_user_dept
	# Set amount
	ud.amount=11.12345
	# Test
	ud.should be_valid
    end

    it "should not accept negative amounts" do
	# get object
	ud=get_new_user_dept
	# Set amount
	ud.amount="-10.5"
	# Test
	ud.should_not be_valid
    end

    it "should not accept letters for amount" do
	# get object
	ud=get_new_user_dept
	# Set amount
	ud.amount="1abc"
	# Test
	ud.should_not be_valid
    end

    it "should not allow mass asignment" do
	# Create Object with mass assignment
	ud1=UserDept.new(@attr)
	# Try to save
	ud1.save.should == false
    end

    it "should have an entry date" do
	# Get today's date
	today=Time.now.utc.strftime("%Y-%m-%d")
	# get object
	ud=get_new_user_dept
	# Save object
	ud.save!
	# Could be created date
	d1=ud.created_at.strftime("%Y-%m-%d")
	# Test
	today.should == d1
    end

    pending "should respond to 'expense'" do
    end

    pending "should link to expense" do
    end
end
