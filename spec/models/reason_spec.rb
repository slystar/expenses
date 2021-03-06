require 'spec_helper'

describe Reason do

    before(:each) do
	@attr={:name => "Home"}
	@attr_expense={:date_purchased => Time.now, :store_id => 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    def create_expense_with_reason()
	@reason=Reason.create!(@attr)
	expense=get_valid_expense
	expense.reason=@reason
	expense.save
	return expense
    end

    it "should create a new instance given valid attributes" do
	Reason.create!(@attr)
    end

    it "should have a default app_version" do
	object=Reason.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=Reason.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a reason" do
	no_reason=Reason.new(@attr.merge(:name => ""))
	no_reason.should_not be_valid
    end

    it "should require a unique reason" do
	Reason.create!(@attr)
	reason=Reason.new(@attr)
	reason.should_not be_valid
    end

    it "should require a unique reason, case insensitive" do
	r1=Reason.create!(@attr)
	name=r1.name
	r2=Reason.new(@attr.merge(:name => name.upcase))
	r1.name.should_not == r2.name
	r2.should_not be_valid
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

    it "should respond to expenses" do
	reason=Reason.new(@attr)
	reason.should respond_to(:expenses)
    end

    it "should have expenses attributes" do
	expense=create_expense_with_reason
	Expense.create!(@attr_expense)
	Expense.create!(@attr_expense.merge(:reason_id => 2))
	@reason.expenses.size.should == 2
    end

    it "should have the right associated expense" do
	expense=create_expense_with_reason
	@reason.should == expense.reason
    end

    it "should not be destroyed if reason has expenses" do
	expense=create_expense_with_reason
	reason=expense.reason
	reason.destroy
	reason.should_not be_destroyed
    end

    it "should have an error if it has expenses and destroy is called" do
	expense=create_expense_with_reason
	reason=expense.reason
	reason.destroy
	reason.errors.size.should == 1
    end

    it "should have an error containing model name if it has expenses and destroy is called" do
	expense=create_expense_with_reason
	reason=expense.reason
	reason.destroy
	reason.errors.messages.values.flatten.grep(/Reason/).size.should > 0
    end

    it "should be destroyable if reason has no expenses" do
	expense=create_expense_with_reason
	reason=expense.reason
	expense.destroy
	reason.destroy
	reason.should be_destroyed
    end
end
