require 'spec_helper'

describe Expense do

    before(:each) do
	@store=Store.create(:name => 'Future shop')
	@reason=Reason.create(:name => 'TV')
	@pay_method=PayMethod.create(:name => 'cash')
	@attr={:date_purchased => Time.now, :store_id => @store.id, :pay_method_id => @pay_method.id, :reason_id => @reason.id, :user_id => 1, :group_id => 1}
    end

    it "should create a record with valid attributes" do
	Expense.create!(@attr)
    end

    it "should have a date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => nil))
	expense.should_not be_valid
    end

    it "should accept a date for date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => '2011-10-14'))
	expense.should be_valid
    end

    it "should refuse invalid dates for date_purchased" do
	expense=Expense.new(@attr.merge(:date_purchased => '2011 10 14 aaa'))
	expense.should_not be_valid
    end

    it "should have a store" do
	expense=Expense.new(@attr.merge(:store_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing store" do
	expense=Expense.new(@attr)
	expense.store_id=9990000000
	expense.should_not be_valid
    end

    it "should have a pay_method" do
	expense=Expense.new(@attr.merge(:pay_method_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing pay_method" do
	expense=Expense.new(@attr)
	expense.pay_method_id=9990000000
	expense.should_not be_valid
    end

    it "should have a reason" do
	expense=Expense.new(@attr.merge(:reason_id => nil))
	expense.should_not be_valid
    end

    it "should have an existing reason" do
	expense=Expense.new(@attr)
	expense.reason_id=9990000000
	expense.should_not be_valid
    end

    it "should have a user_id" do
	expense=Expense.new(@attr.merge(:user_id => nil))
	expense.should_not be_valid
    end

    pending "should map to an existing user" do
	expense=Expense.new(@attr)
	expense.user_id=9990000000
	expense.should_not be_valid
    end

    it "should have a group_id" do
	expense=Expense.new(@attr.merge(:group_id => nil))
	expense.should_not be_valid
    end

    pending "should map to an existing group" do
	expense=Expense.new(@attr)
	expense.group_id=9990000000
	expense.should_not be_valid
    end

    it "should have an amount"

    it "should only allow numbers in amount"

    it "should not be created with a process date"

    it "should not be created with process flag set to true"

    it "should not be destroyable if it's been processed"

    it "should be destroyable if it hasn't been processed"

    pending "Review this test"
end
