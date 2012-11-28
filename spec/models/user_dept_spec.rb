require 'spec_helper'

describe UserDept do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    def get_new_user_dept
	# Create user
	u1=User.create!(:user_name => 'user1', :password => 'testpassworduserdept')
	# No methods are mass assignable
	ud=UserDept.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=@attr[:to_user_id]
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
	invalid_user_id=1
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

    pending "should require a valid to_user_id" do
	# Should not allow an empty value
	# Should require a valid user
    end

    pending "should require an amount" do
    end

    pending "should not accept more than 2 decimal places in amount" do
    end

    pending "should not accept negative amounts" do
    end

    pending "should not allow mass asignment" do
    end

    pending "should have an entry date" do
	# Could be created date
    end
  pending "add some examples to (or delete) #{__FILE__}"
end
