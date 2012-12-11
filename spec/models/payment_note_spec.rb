require 'spec_helper'

describe PaymentNote do

    before(:each) do
	@attr={:user_payment_id => 1, :user_id => 1, :note => "This is a note"}
    end

    def get_new_user_payment
	attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
	# Create user
	u1=User.create!(:user_name => 'user1', :password => 'testpassworduserdept')
	u2=User.create!(:user_name => 'user2', :password => 'testpassworduserdept')
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
end
