require 'spec_helper'

describe Reason do

    before(:each) do
	@attr={:name => "Home"}
    end

    it "should create a new instance given valid attributes" do
	Reason.create!(@attr)
    end

    it "should require a reason" do
	no_reason=Reason.new(@attr.merge(:name => ""))
	no_reason.should_not be_valid
    end

    it "should be unique" do
	Reason.create!(@attr)
	reason=Reason.new(@attr)
	reason.should_not be_valid
    end

    it "should be unique, case insensitive" do
	Reason.create!(@attr)
	upcased=@attr.inject({}) { |h, (k, v)| h[k] = v.upcase; h }
	reason=Reason.new(upcased)
	upcased.should_not == @attr and reason.should_not be_valid
    end

    it "should have a maximum of characters" do
	reason=Reason.new(@attr.merge(:name => "a" * 51))
	reason.should_not be_valid
    end
end
