require 'spec_helper'

describe Store do

    before(:each) do
	@attr={:store => "Future Shop"}
    end

    it "should create a new instance given valid attributes" do
	Store.create!(@attr)
    end

    it "should require a store" do
	no_store=Store.new(@attr.merge(:store => ""))
	no_store.should_not be_valid
    end

    it "should be unique" do
	Store.create!(@attr)
	store=Store.new(@attr)
	store.should_not be_valid
    end

    it "should be unique, case insensitive" do
	Store.create!(@attr)
	store=Store.new(@attr.merge(:store => "FUTURE SHOP"))
	store.should_not be_valid
    end

    it "should have a maximum of characters" do
	store=Store.new(@attr.merge(:store => "a" * 51))
	store.should_not be_valid
    end
end
