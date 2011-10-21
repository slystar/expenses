require 'spec_helper'

describe PayMethod do

    before(:each) do
	@attr={:name => "Credit card"}
    end

    it "should create a new instance given valid attributes" do
	PayMethod.create!(@attr)
    end

    it "should require a pay_method" do
	no_pay_method=PayMethod.new(@attr.merge(:name => ""))
	no_pay_method.should_not be_valid
    end

    it "should be unique" do
	PayMethod.create!(@attr)
	pay_method=PayMethod.new(@attr)
	pay_method.should_not be_valid
    end

    it "should be unique, case insensitive" do
	PayMethod.create!(@attr)
	upcased=@attr.inject({}) { |h, (k, v)| h[k] = v.upcase; h }
	pay_method=PayMethod.new(upcased)
	upcased.should_not == @attr and pay_method.should_not be_valid
    end

    it "should have a maximum of characters" do
	pay_method=PayMethod.new(@attr.merge(:name => "a" * 51))
	pay_method.should_not be_valid
    end
end
