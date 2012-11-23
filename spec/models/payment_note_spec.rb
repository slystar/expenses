require 'spec_helper'

describe PaymentNote do

    before(:each) do
	@attr={:user_payment_id => 1, :user_id => 1, :note => "This is a note"}
    end

    it "should create a new instance given valid attributes" do
	PaymentNote.create!(@attr)
    end

    pending "should not have a blank note" do
    end

    pending "should have a user_id" do
    end

    pending "should map to a valid user" do
    end

    pending "should have a note date" do
	# Can use created date
    end

    pending "should respond to a user_payment method" do
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
