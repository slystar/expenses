require 'spec_helper'

describe PaymentNote do

    before(:each) do
	@attr={:user_payment_id => 1, :user_id => 1, :note => "This is a note"}
	@new_user_id = 1
    end

    def get_new_user_payment
	attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
	# Create user
	u1=get_next_user
	u2=get_next_user
	# No methods are mass assignable
	up=UserPayment.new()
	# Add attributes
	up.from_user_id=u1.id
	up.to_user_id=u2.id
	up.amount=attr[:amount]
	# Return object
	return up
    end

    def get_new_payment_note
	# Get a user_payment object
	up=get_new_user_payment
	# Create a user_payment
	up.save!
	# No methods are mass assignable
	p=PaymentNote.new(@attr)
	# Add attributes
	p.user_payment_id=up.id
	# Return object
	return p
    end

    it "should create a new instance given valid attributes" do
	# get object
	p=get_new_payment_note
	# Save object
	p.save.should == true
    end

    it "should have a default app_version" do
	object=get_new_payment_note
	object.save!
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=get_new_payment_note
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should not have a blank note" do
	# Create object
	p=PaymentNote.new(@attr)
	# Set note to blank
	p.note=''
	# Test
	p.should_not be_valid
	# Set note to nil
	p.note=nil
	# Test
	p.should_not be_valid
    end

    it "should require a valid user_id" do
	# Variables
	invalid_user_id=99999
	# Create records
	p1=PaymentNote.new(@attr.merge(:user_id => nil))
	p2=PaymentNote.new(@attr.merge(:user_id => invalid_user_id))
	# Make sure user does not exist
	User.where(:id =>invalid_user_id).should be_empty
	# Should not allow an empty value
	p1.should_not be_valid
	# Should require a valid user
	p2.should_not be_valid
    end

    it "should map to a valid user_payment_id" do
	# Variables
	invalid_user_payment_id=99999
	# Create records
	p1=PaymentNote.new(@attr.merge(:user_payment_id => nil))
	p2=PaymentNote.new(@attr.merge(:user_payment_id => invalid_user_payment_id))
	# Make sure user does not exist
	PaymentNote.where(:id =>invalid_user_payment_id).should be_empty
	# Should not allow an empty value
	p1.should_not be_valid
	# Should require a valid user
	p2.should_not be_valid
    end

    it "should have a note date" do
	# Get today's date
	today=Time.now.utc.strftime("%Y-%m-%d")
	# get object
	p=get_new_payment_note
	# Save object
	p.save!
	# Could be created date
	d1=p.created_at.strftime("%Y-%m-%d")
	# Test
	today.should == d1
    end

    it "should respond to a user_payment method" do
	# Create Object
	p1=PaymentNote.new()
	# Test
	p1.should respond_to(:user_payment)
    end

    it "should be able to list user_payments" do
	# get object
	p=get_new_payment_note
	# get user_payment
	up=p.user_payment
	# Test
	up.id.should == p.user_payment_id
    end

    it "should not be destroyable if the user_payment has been approved" do
	# get object
	p=get_new_payment_note
	# Get user_payment
	up=p.user_payment
	# Approve user_payment
	up.approve
	up.reload
	# Destroy payment_note
	p.destroy
	# Test
	up.approved.should == true
	p.should_not be_destroyed
    end

    it "should be destroyable if the user_payment has not been approved" do
	# get object
	p=get_new_payment_note
	# Get user_payment
	up=p.user_payment
	# Destroy payment_note
	p.destroy
	# Test
	up.approved.should == false
	p.should be_destroyed
    end

    it "should allow destruction of notes if no other users commented" do
	# get object
	p=get_new_payment_note
	p.save!
	# Get user_payment
	up=p.user_payment
	# get 2nd object
	p2=PaymentNote.new(@attr)
	# Add to user_payment
	p2.user_payment_id=up.id
	p2.save!
	# Reload
	up.reload
	# Test
	up.payment_notes.size.should == 2
	# Delete both
	p.destroy
	p2.destroy
	# Test
	p.should be_destroyed
	p2.should be_destroyed
    end

    it "should only allow destruction of notes following other user notes" do
	# get object
	p=get_new_payment_note
	p.save!
	# Get user_payment
	up=p.user_payment
	# Get users
	u1=p.user
	u2=get_next_user
	# get another PaymentNote
	p2=PaymentNote.new(@attr)
	# Set attributes
	p2.user_payment_id=up.id
	p2.user_id=u2.id
	p2.save!
	# get another PaymentNote
	p3=PaymentNote.new(@attr)
	# Set attributes
	p3.user_payment_id=up.id
	p3.user_id=p.user_id
	p3.save!
	# Reload
	up.reload
	# Test
	up.payment_notes.size.should == 3
	p2.user_id.should_not == p.user_id
	# Delete all
	p.destroy
	p2.destroy
	p3.destroy
	# Test
	p.should_not be_destroyed
	p2.should_not be_destroyed
	p3.should be_destroyed
	p.can_be_destroyed?(u1).should == false
	p2.can_be_destroyed?(u1).should == false
	p3.can_be_destroyed?(u1).should == true
    end

    it "should respond to method can_be_destroyed?" do
	# get object
	p=get_new_payment_note
	p.save!
	# Test
	p.should respond_to(:can_be_destroyed?)
    end

    it "should respond to method delete_note" do
	# get object
	p=get_new_payment_note
	p.save!
	# Test
	p.should respond_to(:delete_note)
    end

    it "should have attribute 'deleted' be false on creation" do
	# get object
	p=get_new_payment_note
	# Test
	p.deleted.should == false
    end

    it "should not actually delete note, just hide it" do
	# get object
	p=get_new_payment_note
	p.save!
	# Test
	p.deleted.should == false
	# Delete note
	p.delete_note
	# Reload
	p.reload
	# Test
	p.deleted.should == true
	p.should_not be_destroyed
    end
end
