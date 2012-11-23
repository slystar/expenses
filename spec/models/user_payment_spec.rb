require 'spec_helper'

describe UserPayment do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    it "should create a new instance given valid attributes" do
	UserPayment.create!(@attr)
    end

    pending "should require a valid from_user_id" do
	# Should not allow an empty value
	# Should require a valid user
    end

    pending "should require a valid to_user_id" do
	# Should not allow an empty value
	# Should require a valid user
    end

    pending "should have an amount" do
    end

    pending "should not accept letters for amount" do
    end

    pending "should not accept more tahn 2 decimals in amount" do
    end

    pending "should not accept negative amounts" do
    end

    pending "should not allow mass asignment" do
    end

    pending "should respond to a payment_notes method" do
    end

    pending "should be able to list all related notes" do
    end

    pending "should not allow a new entry with approved set to true" do
    end

    pending "should have a method 'approve'" do
    end

    pending "should not allow approved to be set without approved_date" do
    end

    pending "should not allow approved_date to be set without approved set to true" do
    end

    pending "should have an entry date" do
	# Can use created date
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
