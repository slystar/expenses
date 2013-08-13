require 'spec_helper'

describe Store do

    def get_store_attr
	{:name => Faker::Company.name}
    end

    before(:each) do
	@attr=get_store_attr
	@object=FactoryGirl.build(:store)
	@attr_expense={:date_purchased => Time.now, :store_id => 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    def create_expense_with_store()
	@store=Store.create!(@attr)
	expense=get_valid_expense
	expense.store=@store
	expense.save
	return expense
    end

    it "should create a new instance given valid attributes" do
	@object.should be_valid
    end

    it "should have a default app_version" do
	object=Store.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=Store.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a store name" do
	FactoryGirl.build(:store, name: nil).should_not be_valid
    end

    it "should be unique" do
	Store.create!(@attr)
	store=Store.new(@attr)
	store.should_not be_valid
    end

    it "should be unique, case insensitive" do
	Store.create!(@attr)
	upcased=@attr.inject({}) { |h, (k, v)| h[k] = v.upcase; h }
	store=Store.new(upcased)
	upcased.should_not == @attr and store.should_not be_valid
    end

    it "should have a maximum of characters" do
	store=Store.new(@attr.merge(:name => "a" * 51))
	store.should_not be_valid
    end

    it "should respond to expenses" do
	store=Store.new(@attr)
	store.should respond_to(:expenses)
    end

    it "should have expenses attributes" do
	expense=create_expense_with_store
	Expense.create!(@attr_expense)
	Expense.create!(@attr_expense.merge(:store_id => 2))
	@store.expenses.size.should == 2
    end

    it "should have the right associated expense" do
	expense=create_expense_with_store
	@store.should == expense.store
    end

    it "should not be destroyed if store has expenses" do
	expense=create_expense_with_store
	store=expense.store
	store.destroy
	store.should_not be_destroyed
    end

    it "should have an error if it has expenses and destroy is called" do
	expense=create_expense_with_store
	store=expense.store
	store.destroy
	store.errors.size.should == 1
    end

    it "should have an error containing model name if it has expenses and destroy is called" do
	expense=create_expense_with_store
	store=expense.store
	store.destroy
	store.errors.messages.values.flatten.grep(/Store/).size.should > 0
    end

    it "should be destroyable if store has no expenses" do
	expense=create_expense_with_store
	store=expense.store
	expense.destroy
	store.destroy
	store.should be_destroyed
    end

    it "should have a default parent_id value" do
	object=Store.create!(@attr)
	object.parent_id.should == 0
    end

    it "should only allow valid parents" do
	# Create stores
	object=Store.create!(@attr)
	object2=Store.create!(get_store_attr)
	# Set invalid parent
	object.parent_id = Store.last.id + 100
	# Test
	object.should_not be_valid
	# Set valid parent
	object.parent=object2
	# Test
	object.should be_valid
    end

    it "should not destroy a parent" do
	# Create stores
	object=Store.create!(@attr)
	object2=Store.create!(get_store_attr)
	# Make parent
	object2.parent=object
	# Save 
	object2.save!
	# Try to delete first
	object.destroy
	# Should not be destroyed
	object.should_not be_destroyed
    end
end
