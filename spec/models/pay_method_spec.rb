require 'spec_helper'

describe PayMethod do

    before(:each) do
	@attr={:name => "Credit card"}
	@attr_expense={:date_purchased => Time.now, :store_id => 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    def create_expense_with_pay_method()
	@pay_method=PayMethod.create(@attr)
	expense=get_valid_expense
	expense.pay_method=@pay_method
	expense.save
	return expense
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

    it "should respond to expenses" do
	pay_method=PayMethod.new(@attr)
	pay_method.should respond_to(:expenses)
    end

    it "should have expenses attributes" do
	expense=create_expense_with_pay_method
	Expense.create(@attr_expense)
	Expense.create(@attr_expense.merge(:pay_method_id => 2))
	@pay_method.expenses.size.should == 2
    end

    it "should have the right associated expense" do
	expense=create_expense_with_pay_method
	@pay_method.should == expense.pay_method
    end

    it "should not be destroyed if pay_method has expenses" do
	expense=create_expense_with_pay_method
	pay_method=expense.pay_method
	pay_method.destroy
	pay_method.should_not be_destroyed
    end

    it "should have an error if it has expenses and destroy is called" do
	expense=create_expense_with_pay_method
	pay_method=expense.pay_method
	pay_method.destroy
	pay_method.errors.size.should == 1
    end

    it "should have an error containing model name if it has expenses and destroy is called" do
	expense=create_expense_with_pay_method
	pay_method=expense.pay_method
	pay_method.destroy
	pay_method.errors.messages.values.flatten.grep(/PayMethod/).size.should > 0
    end

    it "should be destroyable if pay_method has no expenses" do
	expense=create_expense_with_pay_method
	pay_method=expense.pay_method
	expense.destroy
	pay_method.destroy
	pay_method.should be_destroyed
    end
end
