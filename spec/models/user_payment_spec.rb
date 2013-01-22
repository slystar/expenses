require 'spec_helper'

describe UserPayment do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    def get_new_user(name)
	# Create new user
	u1=User.create!(:user_name => name, :password => 'testpassworduserdept')
	# Return user object
	return u1
    end

    def get_new_user_payment
	# Create user
	u1=get_new_user('user1')
	u2=get_new_user('user2')
	# No methods are mass assignable
	up=UserPayment.new()
	# Add attributes
	up.from_user_id=u1.id
	up.to_user_id=u2.id
	up.amount=@attr[:amount]
	# Return object
	return up
    end

    it "should create a new instance given valid attributes" do
	# get object
	up=get_new_user_payment
	# Save object
	up.save.should == true
    end

    it "should require a valid from_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	up1=UserPayment.new(@attr.merge(:from_user_id => nil))
	up2=UserPayment.new(@attr.merge(:from_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	up1.should_not be_valid
	# Should require a valid user
	up2.should_not be_valid
    end

    it "should require a valid to_user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	up1=UserPayment.new(@attr.merge(:to_user_id => nil))
	up2=UserPayment.new(@attr.merge(:to_user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	up1.should_not be_valid
	# Should require a valid user
	up2.should_not be_valid
    end

    it "should not have the same from_user and to_user" do
	# get object
	up=get_new_user_payment
	# Set to_user
	up.to_user_id=up.from_user_id
	# Test
	up.should_not be_valid
    end

    it "should require an amount" do
	# get object
	up=get_new_user_payment
	# Set amount to nil
	up.amount=nil
	# Test
	up.should_not be_valid
    end

    it "should accept an integer in amount" do
	# get object
	up=get_new_user_payment
	# Set amount
	up.amount=11
	# Test
	up.should be_valid
    end

    it "should not accept more than 2 decimal places in amount" do
	# get object
	up=get_new_user_payment
	# Set amount
	up.amount=11.12345
	# Test
	up.should_not be_valid
    end

    it "should not accept negative amounts" do
	# get object
	up=get_new_user_payment
	# Set amount
	up.amount="-10.5"
	# Test
	up.should_not be_valid
    end

    it "should not accept letters for amount" do
	# get object
	up=get_new_user_payment
	# Set amount
	up.amount="1abc"
	# Test
	up.should_not be_valid
    end

    it "should not allow mass asignment" do
	# Create Object with mass assignment
	up1=UserPayment.new(@attr)
	# Try to save
	up1.save.should == false
    end

    it "should have an entry date" do
	# Get today's date
	today=Time.now.utc.strftime("%Y-%m-%d")
	# get object
	up=get_new_user_payment
	# Save object
	up.save!
	# Could be created date
	d1=up.created_at.strftime("%Y-%m-%d")
	# Test
	today.should == d1
    end

    it "should respond to a payment_notes method" do
	# Create Object
	up1=UserPayment.new()
	# Test
	up1.should respond_to(:payment_notes)
    end

    it "should be able to list all related notes" do
	# get object
	up=get_new_user_payment
	# Save upser_payment
	up.save!
	# Add notes
	up.payment_notes.new({:user_id => 1, :note => "This is a note1"})
	up.payment_notes.new({:user_payment_id => 1, :user_id => 1, :note => "This is a note2"})
	# Save object
	up.save.should == true
	# Count notes
	up.payment_notes.size.should == 2
    end

    it  "should allow an entered record to have approved changed to true" do
	# get object
	up=get_new_user_payment
	# Save record
	up.save.should == true
	# Set approved
	up.approved=true
	up.approved_date=Time.now
	# Test
	up.save.should == true
    end

    it "should not allow a new entry with approved set to true" do
	# get object
	up=get_new_user_payment
	# Set approved
	up.approved=true
	# Test
	up.save.should == false
	up.errors.messages.size.should > 0
    end

    it "should not allow a new entry with approved_date set" do
	# get object
	up=get_new_user_payment
	# Set approved
	up.approved_date=Time.now
	# Test
	up.save.should == false
	up.errors.messages.size.should > 0
    end

    it "should have a method 'approve'" do
	# get object
	up=get_new_user_payment
	# Save record
	up.save.should == true
	# Approve payment
	up.approve
	# Refresh record
	up.reload
	# Test
	up.approved.should == true
	up.approved_date.should_not be_nil
    end

    it "should have the correct approved_date" do
	# Date format
	date_format='%Y-%m-%d'
	# Get date
	today=Time.now.utc.strftime(date_format)
	# get object
	up=get_new_user_payment
	# Save record
	up.save.should == true
	# Approve payment
	up.approve
	# Refresh record
	up.reload
	# Get approved_date datetime
	approved_datetime=up.approved_date
	# Get approved date
	approved_date_date=approved_datetime.strftime(date_format)
	# Test
	approved_date_date.should == today
    end

    it "should not allow approved to be set without approved_date" do
	# get object
	up=get_new_user_payment
	# Save record
	up.save!
	# Set approved
	up.approved=true
	# Set aproved date
	up.approved_date=nil
	# Test
	up.save.should == false
	up.errors.messages.size.should > 0
    end

    it "should not allow approved_date to be set without approved set to true" do
	# get object
	up=get_new_user_payment
	# Save record
	up.save!
	# Set approved
	up.approved=nil
	# Set aproved date
	up.approved_date=Time.now
	# Test
	up.save.should == false
	up.errors.messages.size.should > 0
    end

    it "should have all new records with process_flag set to false" do
	# get object
	ud=get_new_user_payment
	# Create record
	ud.save!
	# Reload data
	ud.reload
	# Test
	ud.process_flag.should == false
    end

    it "should not have a new record with process_flag set to true" do
	# get object
	ud=get_new_user_payment
	# Set amount
	ud.process_flag=true
	# Test
	ud.should_not be_valid
    end

    it "should be able to set process_flag of an existing record" do
	# get object
	ud=get_new_user_payment
	# Create record
	ud.save!
	# Set process_flag
	ud.process_flag=true
	# Save modification
	ud.save!
	# Reload data
	ud.reload
	# Test
	ud.process_flag.should == true
    end

    it "should link to UpdateBalanceHistory" do
	# Get user
	u1=get_new_user('user5')
	# get object
	ud=get_new_user_payment
	# Create record
	ud.save!
	# Approve payment
	ud.approve
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(2)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Reload
	ud.reload
	# Test
	ud.update_balance_history.should == ubh
    end
end
