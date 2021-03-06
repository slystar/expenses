require 'spec_helper'

describe UpdateBalanceHistory do

    before(:each) do
	@new_user_id=1
	# Get a next user
	@u=get_next_user
	@attr={:user_id => @u.id}
    end

    it "should create a new instance given valid attributes" do
	UpdateBalanceHistory.create!(@attr)
    end

    it "should have a default app_version" do
	object=UpdateBalanceHistory.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=UpdateBalanceHistory.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should require a user" do
	obj=UpdateBalanceHistory.new(@attr.merge(:user_id => nil))
	obj.should_not be_valid
    end

    it "should track creation date" do
	# Save timestamp format
	ts_format="%Y-%m-%d"
	# Get date
	today=Time.now.utc.strftime(ts_format)
	# Get new user
	new_user=get_next_user
	# Create object
	obj=UpdateBalanceHistory.new(@attr)
	# Save Object
	obj.save!
	# Reload
	obj.reload
	# Get date
	create_date=obj.created_at
	# Test date
	create_date.strftime(ts_format).should == today
	# Modify object
	obj.user=new_user
	# Save new object
	obj.save
	# Test date, should not have changed
	obj.created_at.should == create_date
    end

    it "should link to user" do
	# Create object
	obj=UpdateBalanceHistory.new(@attr)
	# Test user
	obj.user.should == @u
    end

    it "should link to user_payments" do
	# Set amount
	payment1=3.30
	payment2=5.00
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Create new UserPayment
	up1=add_user_payment(u1,u2,payment1)
	up2=add_user_payment(u2,u1,payment2)
	# Update balances
	UserBalance.update_balances(u1.id)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Should link to user_payments
	ubh.user_payments.size.should == 2
    end

    it "should link to user_depts" do
	# Set amount
	dept1=12.50
	dept2=14.50
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Get an expense record
	expense=get_valid_expense
	# Create new UserDept
	ud1=add_user_dept(u1,u2,dept1,expense.id)
	ud2=add_user_dept(u1,u2,dept2,expense.id)
	# Update balances
	UserBalance.update_balances(u1.id)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Should link to user_depts
	ubh.user_depts.size.should == 2
    end

    it "should link to user_balances" do
	# Set amount
	existing_balance1_1=15.25
	dept1=12.50
	dept2=14.50
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Get an expense record
	expense=get_valid_expense
	# Create new UserDept
	ud1=add_user_dept(u1,u2,dept1,expense.id)
	ud2=add_user_dept(u1,u2,dept2,expense.id)
	# Create new UserBalance
	ub1=add_balance(u1,u2,existing_balance1_1)
	# Update balances
	UserBalance.update_balances(u1.id)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Should link to user_balances
	ubh.user_balances.size.should == 4
    end

    it "should link all rows used in 'update_balance'" do
	# Set amount
	dept1=12.50
	dept2=14.50
	dept3=1634.50
	payment1=3.30
	payment2=1.30
	payment3=220.95
	existing_balance=500.25
	existing_balance1_1=50.11
	# Get an expense record
	expense=get_valid_expense
	# Create users
	u1=get_next_user
	u2=get_next_user
	# Create new UserDept
	ud1=add_user_dept(u1,u2,dept1,expense.id)
	ud2=add_user_dept(u1,u2,dept2,expense.id)
	ud3=add_user_dept(u2,u1,dept3,expense.id)
	# Create new UserPayment
	up1=add_user_payment(u1,u2,payment1)
	up2=add_user_payment(u2,u1,payment2)
	up3=add_user_payment(u1,u2,payment3)
	# Create new UserBalance
	ub=add_balance(u2,u1,existing_balance)
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(2)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Test updatebalancehistoryid
	ud1.reload.update_balance_history_id.should == ubh.id
	ud2.reload.update_balance_history_id.should == ubh.id
	ud3.reload.update_balance_history_id.should == ubh.id
	up1.reload.update_balance_history_id.should == ubh.id
	up2.reload.update_balance_history_id.should == ubh.id
	up3.reload.update_balance_history_id.should == ubh.id
	ub.reload.update_balance_history_id.should== ubh.id
	# Last UserBalances should have ids as well
	UserBalance.all[-2,2].each do |ub_rec|
	    ub_rec.update_balance_history_id.should == ubh.id
	end
	# Run again
	# Create new UserDept
	ud4=add_user_dept(u1,u2,dept1,expense.id)
	# Create new UserPayment
	up4=add_user_payment(u1,u2,payment1)
	# Create new UserBalance
	ub5=add_balance(u1,u2,existing_balance1_1)
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(2)
	# Get last UpdateBalanceHistory
	ubh=UpdateBalanceHistory.last
	# Test updatebalancehistoryid
	ud4.reload.update_balance_history_id.should == ubh.id
	up4.reload.update_balance_history_id.should == ubh.id
	ub5.reload.update_balance_history_id.should == ubh.id
    end
end
