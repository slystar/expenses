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

    def create_return
	@exp=get_valid_expense
	attr_return={:description => Faker::Company.name, :expense_id => @exp.id, :transaction_date => Date.today, :user_id => @exp.user_id, :amount => @exp.amount - 1}
	Return.create!(attr_return)
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

    it "should have a default app_version" do
	object=get_new_user_payment
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_new_user_payment
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
	# TEst
	up.should respond_to(:approve)
    end

    it "should 'approve' only from :to_user_id" do
	# get object
	up=get_new_user_payment
	# Save record
	up.save.should == true
	# Test: Approve payment
	up.approve(up.from_user_id).should == false
	up.approve(up.to_user_id).should == true
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
	up.approve(up.to_user_id)
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
	ud.approve(ud.to_user_id)
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

    it "should allow creation of payment_notes" do
	# get object
	up=get_new_user_payment
	# Save UserPayment
	up.save!
	# Get new note
	note=up.payment_notes.new
	# Set required fields
	note.note='Test note'
	note.user_id=up.from_user_id
	# Save new note
	note.save!
	# Create second note
	note2=up.payment_notes.create({:note => 'test 2',:user_id => up.to_user_id})
	# Save second note
	note2.save!
	# Test
	up.payment_notes.size.should == 2
    end

    it "should allow modification of payment_notes" do
	# Variables
	old_note='test 1'
	new_note='test 2'
	# get object
	up=get_new_user_payment
	# Save UserPayment
	up.save!
	# Get new note
	note=up.payment_notes.new
	# Set required fields
	note.note=old_note
	note.user_id=up.from_user_id
	# Save new note
	note.save!
	# Modify note
	note.note=new_note
	# Save note
	note.save!
	# Reload UserPayment
	up.reload
	# Test
	up.payment_notes.first.note.should == new_note
	up.payment_notes.first.note.should_not == old_note
    end

    it "should not be destroyable if it's been approved." do
	# get object
	up=get_new_user_payment
	# Save record
	up.save!
	# Set approved flag
	up.approve(up.to_user_id)
	# Reload
	up.reload
	# Test
	up.destroy
	up.should_not be_destroyed
	up.errors.messages.size.should > 0
    end

    it "should not be destroyable if it's been processed." do
	# get object
	up=get_new_user_payment
	# Save
	up.save!
	# Set approved flag
	up.process_flag=true
	# Save
	up.save!
	# Reload
	up.reload
	# Test
	up.destroy
	up.should_not be_destroyed
	up.errors.messages.size.should > 0
    end

    it "should be destroyable if it hasn't been processed." do
	# get object
	up=get_new_user_payment
	# Set approved flag
	up.process_flag=false
	# Save
	up.save!
	# Reload
	up.reload
	# Test
	up.destroy
	up.should be_destroyed
    end

    it "should respond to method :visible_payment_notes" do
	# get object
	up=get_new_user_payment
	# Test
	up.should respond_to(:visible_payment_notes)
    end

    it "should return only visible notes if requested" do
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
	# Get last note
	pn=up.payment_notes.last
	# Delete last note
	pn.delete_note
	# Test
	up.payment_notes.size.should == 2
	up.visible_payment_notes.size.should == 1
    end

    it "should link to a valid user through waiting_on_user_id" do
	# get object
	up=get_new_user_payment
	# Set attribute
	up.waiting_on_user_id=up.to_user_id
	# Test
	up.waiting_on_user.should respond_to(:user_name)
	up.waiting_on_user.user_name.should == up.to_user.user_name
    end

    it "should default :waiting_on_user_id be :to_user_id on creation" do
	# get object
	up=get_new_user_payment
	# Save
	up.save!
	# Test
	up.waiting_on_user_id.should == up.to_user_id
    end

    it "should be able to set waiting_on_user_id to nil" do
	# get object
	up=get_new_user_payment
	# Set attribute
	up.waiting_on_user_id=up.to_user_id
	# Test
	up.should be_valid
	up.save!
	# Set attribute
	up.waiting_on_user_id=nil
	# Test
	up.should be_valid
	up.save!
	up.waiting_on_user_id.should == nil
    end

    it "should have a return_payment class method" do
	# Save object
	UserPayment.should respond_to(:return_payment)
    end

    it "should be able to add a return_payment" do
	# Variables
	amount=10
	u1=get_new_user('user1')
	u2=get_new_user('user2')
	today=Time.now.utc.strftime("%Y-%m-%d")
	# Get a return
	return_obj=create_return
	# Create a return payment
	UserPayment.return_payment(return_obj.id,u1.id,u2.id,amount)
	# Get record
	up=UserPayment.last
	# Test
	up.from_user_id.should == u1.id
	up.to_user_id.should == u2.id
	up.amount.should == amount
	up.process_date.should be_nil
	up.process_flag.should == false
	up.approved.should == true
	up.approved_date.strftime("%Y-%m-%d").should == today
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(2)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Reload
	up.reload
	# Test
	up.update_balance_history.should == ubh
	up.process_date.strftime("%Y-%m-%d").should == today
	up.process_flag.should == true
    end

    it "should return the user_payment_id when doing a return_payment" do
	# Variables
	amount=10
	u1=get_new_user('user1')
	u2=get_new_user('user2')
	# Get a return
	return_obj=create_return
	# Create a return payment
	id=UserPayment.return_payment(return_obj.id,u1.id,u2.id,amount)
	# Test
	id.should == UserPayment.last.id
    end

    it "should have a default return_id" do
	# Get UserPayment
	object=get_new_user_payment
	# Save
	object.save!
	# Test
	object.return_id.should == 0
    end

    it "should have a link to returns" do
	# Variables
	amount=10
	u1=get_new_user('user1')
	u2=get_new_user('user2')
	# Get a return
	return_obj=create_return
	# Create a return payment
	id=UserPayment.return_payment(return_obj.id,u1.id,u2.id,amount)
	# Get that UserPayment
	up=UserPayment.find(id)
	# Test
	up.return.should == return_obj
    end

    it "should only allow valid returns" do
	# Variables
	invalid_return_id=999
	# Get UserPayment
	object=get_new_user_payment
	# Save
	object.save!
	# Set return_id 
	object.return_id=invalid_return_id
	# Test
	object.should_not be_valid
    end
end
