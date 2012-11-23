require 'spec_helper'

describe UserPayment do

    before(:each) do
	@attr={:from_user_id => 1, :to_user_id => 1, :amount => 11.23}
    end

    it "should create a new instance given valid attributes" do
	UserPayment.create!(@attr)
    end

    pending "should have a from_user_id" do
    end

    pending "should have a from_user that exists" do
    end

    pending "should have a to_user_id" do
    end

    pending "should have a to_user that exists" do
    end

    pending "should have an amount" do
    end

    pending "should not accept letters for amount" do
    end

    pending "should not accept more tahn 2 decimals in amount " do
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
