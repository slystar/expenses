require 'spec_helper'

describe UserDept do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    it "should create a new instance given valid attributes" do
	UserDept.create!(@attr)
    end

    pending "should require a valid from_user_id" do
	# Should not allow an empty value
	# Should require a valid user
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
