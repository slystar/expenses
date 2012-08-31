require 'spec_helper'

describe Group do

    before(:each) do
	@attr={:name => "Group 1", :description => 'group 1 desc'}
	@attr_expense={:date_purchased => Time.now, :store_id => 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    def create_expense_with_group()
	@group=Group.create!(@attr)
	expense=get_valid_expense
	expense.group=@group
	expense.save
	return expense
    end
    it "should create a new instance given valid attributes" do
	Group.create!(@attr)
    end

    it "should require a name" do
	group=Group.new(@attr.merge(:name => ""))
	group.should_not be_valid
    end

    it "should be unique" do
	Group.create!(@attr)
	group=Group.new(@attr)
	group.should_not be_valid
    end

    it "should be unique, case insensitive" do
	Group.create!(@attr)
	upcased=@attr.inject({}) { |h, (k, v)| h[k] = v.upcase; h }
	group=Group.new(upcased)
	upcased.should_not == @attr and group.should_not be_valid
    end

    it "should have a maximum of characters" do
	group=Group.new(@attr.merge(:name => "a" * 51))
	group.should_not be_valid
    end

    it "should respond to expenses" do
	group=Group.new(@attr)
	group.should respond_to(:expenses)
    end

    it "should have expenses attributes" do
	expense=create_expense_with_group
	group=expense.group
	group_other=Group.create!(@attr.merge(:name => Faker::Name.name))
	Expense.create!(@attr_expense.merge(:group_id => group.id))
	Expense.create!(@attr_expense.merge(:group_id => group_other.id))
	@group.expenses.size.should == 2
    end

    it "should have the right associated expense" do
	expense=create_expense_with_group
	@group.should == expense.group
    end

    it "should not be destroyed if group has expenses" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.should_not be_destroyed
    end

    it "should have an error if it has expenses and destroy is called" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.errors.size.should == 1
    end

    it "should have an error containing model name if it has expenses and destroy is called" do
	expense=create_expense_with_group
	group=expense.group
	group.destroy
	group.errors.messages.values.flatten.grep(/Group/).size.should > 0
    end

    it "should be destroyable if group has no expenses" do
	expense=create_expense_with_group
	group=expense.group
	expense.destroy
	group.destroy
	group.should be_destroyed
    end

    pending "should provide the Group.users function" do
    end

    pending "should have a default ALL group" do
    end

    pending "should not be able to destroy default ALL group" do
    end
end
