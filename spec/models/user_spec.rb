require 'spec_helper'

describe User do

    before(:each) do
	@attr={:user_name => 'test', :password => 'testpassword'}
	@attr_group={:name => "Group user spec", :description => 'group used in user spec tests'}
	@new_user_id=1
    end

     it "should create a new instance given valid attributes" do
	 User.create!(@attr)
     end

    it "should have a default app_version" do
	object=User.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=User.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should have a user_name" do
	user=User.new(@attr.merge(:user_name => ""))
	user.should_not be_valid
    end

    it "should have a unique user_name" do
	User.create!(@attr)
	user=User.new(@attr)
	user.should_not be_valid
    end

    it "should have a unique user_name, case insensitive" do
	u1=User.create!(@attr)
	# Get username
	name=u1.user_name
	# Create 2nd user
	u2=User.new(@attr.merge(:user_name => name.upcase))
	# Make sure they are not the same
	u1.user_name.should_not == u2.user_name
	# Make sure it's unique
	u2.should_not be_valid
    end

    it "should have a password" do
	user=User.new(@attr.merge(:password => ""))
	user.should_not be_valid
    end

    it "should have a password with minimum 8 characters" do
	user=User.new(@attr.merge(:password => "a" * 7))
	user.should_not be_valid
    end

    it "should have an optional name" do
	user=User.new(@attr.merge(:name => "a" * 7))
	user.should be_valid
    end

    it "should have a default group upon creation" do
	user=User.create!(@attr)
	group=user.groups.find{|g| g.name == user.user_name}
	group.should_not be_nil
    end

    it "should be in a minimum of groups on creation" do
	user=User.create!(@attr)
	user.groups.size.should == 1
    end

    it "should have a User.groups method" do
	user=User.create!(@attr)
	user.should respond_to(:groups)
    end

    it "should have a method expenses" do
	user=User.create!(@attr)
	user.should respond_to(:expenses)
    end

    it "should not be destroyable if it has expenses" do
	expense=get_valid_expense
	user=User.create!(@attr)
	expense.user=user
	expense.save
	user.destroy
	user.should_not be_destroyed
    end

    it "should not be destroyable if it has expenses through groups" do
	expense=get_valid_expense
	user=User.create!(@attr)
	group=Group.create!(@attr_group)
	# Create group membership
	attr_group_member={:user_id => user.id, :group_id => group.id}
	GroupMember.create!(attr_group_member)
	# Set expense to use this group
	expense.group_id=group.id
	# Save expense
	expense.save
	# User should be part of the group
	user.groups.should include(group)
	# Try to destroy user
	user.destroy
	user.errors.size.should > 0
	user.should_not be_destroyed
    end

    it "should have default group destroyed on destruction" do
	# Create user
	user=User.create!(@attr)
	# Get all groups count
	groups1=Group.all.size
	# Destroy user
	user.destroy
	# Check if user is destroyed
	user.should be_destroyed
	# Get all groups count
	groups2=Group.all.size
	# Count should be one less
	(groups1 - groups2).should == 1
	# Get default group
	default_group=Group.where(:name => user.user_name)
	# Default group should not exist
	default_group.size.should == 0
    end

    it "should have all group memberships removed on destruction" do
	# Create user
	user=User.create!(@attr)
	# Destroy user, should remove following memberships
	# - group: User
	lambda{user.destroy}.should change(GroupMember,:count).by(-1)
    end

    it "should have a roles method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:roles)
    end

    it "could have roles" do
	# Create user
	user=User.create!(@attr)
	# Add role to user
	user.roles.new({:name => "test_user_role", :description => "Test user role"})
	# Save user should be successfull and add a role
	lambda{user.save}.should change(UserRole,:count).by(1)
    end

    it "should have the first user created be admin" do
	# Create user
	user=User.create!(@attr)
	# Get roles
	roles=user.roles
	# Should have at least one role
	roles.size.should > 0
	# Should have admin role since it's the first user
	roles.detect{|r| r.name =~ /Admin/i}.should_not be_nil
    end

    it "should have the second user created not have any default roles" do
	# Create first user
	user1=User.create!(@attr)
	# Create second user
	user2=User.create!(@attr.merge(:user_name => 'testuser2'))
	# Get roles
	roles=user2.roles
	# Should have 0 roles
	roles.size.should == 0
    end

    it "should respond to a 'user_payments_from' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_payments_from)
    end

    it "should respond to a 'user_payments_to' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_payments_to)
    end

    it "should respond to a 'user_depts_from' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_depts_from)
    end

    it "should respond to a 'user_depts_to' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_depts_to)
    end

    it "should respond to a 'user_balances_from' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_balances_from)
    end

    it "should respond to a 'user_balances_to' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:user_balances_to)
    end

    it "should respond to a 'depts' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:depts)
    end

    it "should respond to a 'credits' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:credits)
    end

    it "should respond to a 'balances' method" do
	# Create user
	user=User.create!(@attr)
	# Should respond to roles
	user.should respond_to(:balances)
    end

    it "should have a 'depts' method list depts" do
	# Variables
	dept1=4.00
	dept2=5.0
	dept3=22.00
	existing_balance=3.50
	# Expected depts
	expected_dept_1_2=dept1 + dept2 + existing_balance
	expected_dept_1_3=dept3
	# Get an expense record
	expense=get_valid_expense
	# Create users
	u1=get_next_user
	u2=get_next_user
	u3=get_next_user
	# Create new UserBalance just to add more rows
	add_balance(u1,u2,existing_balance)
	# Create new UserDept
	add_user_dept(u1,u2,dept1,expense.id)
	add_user_dept(u1,u2,dept2,expense.id)
	add_user_dept(u1,u3,dept3,expense.id)
	# Test: UserBalance created (3 users x 2 records = 6)
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(6)
	# Get u1 depts
	u1_depts=u1.depts
	# Test: get depts
	u1_depts.size.should == 2
	u2.depts.size.should == 0
	u3.depts.size.should == 0
	# Get depts per users
	u1_u2=u1_depts.select{|row| row[:to_user_id] == u2.id}
	u1_u3=u1_depts.select{|row| row[:to_user_id] == u3.id}
	# Test: dept amounts
	u1_u2.size.should == 1
	u1_u2.first[:amount].to_f.should == expected_dept_1_2
	u1_u3.size.should == 1
	u1_u3.first[:amount].to_f.should == expected_dept_1_3
    end

    it "should have a 'credits' method list credits" do
	# Variables
	dept1=4.00
	dept2=5.0
	dept3=22.00
	existing_balance=3.50
	# Expected depts
	expected_credit_2_1=dept1 + dept2 + existing_balance
	expected_credit_3_1=dept3
	# Get an expense record
	expense=get_valid_expense
	# Create users
	u1=get_next_user
	u2=get_next_user
	u3=get_next_user
	# Create new UserBalance just to add more rows
	add_balance(u1,u2,existing_balance)
	# Create new UserDept
	add_user_dept(u1,u2,dept1,expense.id)
	add_user_dept(u1,u2,dept2,expense.id)
	add_user_dept(u1,u3,dept3,expense.id)
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(6)
	# Test: get credits
	u1.credits.size.should == 0
	u2.credits.size.should == 1
	u3.credits.size.should == 1
	# Get credits per users
	u2_u1=u2.credits.select{|row| row[:to_user_id] == u2.id}
	u3_u1=u3.credits.select{|row| row[:to_user_id] == u3.id}
	# Test: credits amounts
	u2_u1.size.should == 1
	u2_u1.first[:amount].to_f.should == expected_credit_2_1
	u3_u1.size.should == 1
	u3_u1.first[:amount].to_f.should == expected_credit_3_1
    end

    it "should have a 'balances' method list balances" do
	# Variables
	dept1=4.00
	dept2=5.0
	dept3=22.00
	existing_balance=3.50
	# Get an expense record
	expense=get_valid_expense
	# Create users
	u1=expense.user
	u2=get_next_user
	u3=get_next_user
	# Create new UserBalance just to add more rows
	add_balance(u1,u2,existing_balance)
	# Create new UserDept
	add_user_dept(u1,u2,dept1,expense.id)
	add_user_dept(u1,u2,dept2,expense.id)
	add_user_dept(u1,u3,dept3,expense.id)
	# Expected balances
	expected_balance_1_2=dept1 + dept2 + existing_balance
	expected_balance_2_1=-expected_balance_1_2
	expected_balance_1_3=dept3
	expected_balance_3_1=-expected_balance_1_3
	expected_balance_2_3=0
	expected_balance_3_2=0
	# Test: UserBalance created
	lambda {
	    # Update balances
	    UserBalance.update_balances(u1.id)
	}.should change(UserBalance,:count).by(6)
	# Test: get balances
	u1.balances.size.should == 2
	u2.balances.size.should == 2
	u3.balances.size.should == 2
	# Get balances
	b_1_2=u1.balances.select{|b| b.to_user_id == u2.id}.first.amount
	b_1_3=u1.balances.select{|b| b.to_user_id == u3.id}.first.amount
	b_2_1=u2.balances.select{|b| b.to_user_id == u1.id}.first.amount
	b_2_3=u2.balances.select{|b| b.to_user_id == u3.id}.first.amount
	b_3_1=u3.balances.select{|b| b.to_user_id == u1.id}.first.amount
	b_3_2=u3.balances.select{|b| b.to_user_id == u2.id}.first.amount
	# Test: credit amounts
	b_2_1.should == expected_balance_2_1
	b_2_1.should < 0
	b_3_1.should == expected_balance_3_1
	b_3_1.should < 0
	# Test: depts
	b_1_2.should == expected_balance_1_2
	b_1_2.should > 0
	b_1_3.should == expected_balance_1_3
	b_1_3.should > 0
	# Test: zero
	b_2_3.should == expected_balance_2_3
	b_2_3.should == 0
	b_3_2.should == expected_balance_3_2
	b_3_2.should == 0
    end

    it "should have method is_admin?" do
	user1=User.create!(@attr)
	user2=get_next_user
	user1.is_admin?.should == true
	user2.is_admin?.should == false
    end

    it "should be able to rename user_name" do
	# Get user
	u1=User.create!(@attr)
	# Reload
	u1.reload
	# Get name info
	old_name=u1.user_name
	new_name=old_name + 'abcd'
	# Set new name
	u1.user_name=new_name
	# Test
	u1.save.should == true
	# Reload
	u1.reload
	# Test
	u1.user_name.should_not == old_name
    end

    it "should have a method to fetch self group" do
	# Get user
	u1=User.create!(@attr)
	# Get group representing self
	self_group=Group.where(:name => u1.user_name).first
	# Test
	u1.self_group.should == self_group
    end

    it "should respond to method :needs_to_approve_user_payments?" do
	# Get user
	u1=User.create!(@attr)
	# Test
	u1.should respond_to(:needs_to_approve_user_payments?)
    end

    it "should know if user_payments require approval" do
	# Get users
	u1=User.create!(@attr)
	u2=get_next_user
	# Create UserPayment
	up=add_user_payment(u2,u1,10,false)
	# Test
	up.approved.should == false
	u1.needs_to_approve_user_payments?.should == true
	# Approve payment
	up.approve
	up.reload
	# Test
	up.approved.should == true
	u1.needs_to_approve_user_payments?.should == false
    end

    it "should respond to method :get_user_payments_waiting_for_approval" do
	# Get user
	u1=User.create!(@attr)
	# Test
	u1.should respond_to(:get_user_payments_waiting_for_approval)
    end

    it "should be able to fetch user_payemtns waiting for approval" do
	# Get users
	u1=User.create!(@attr)
	u2=get_next_user
	# Create UserPayment
	up1=add_user_payment(u2,u1,10,false)
	up2=add_user_payment(u2,u1,10,false)
	# Test
	u1.get_user_payments_waiting_for_approval.size.should == 2
	# Approve
	up1.approve
	# Test
	u1.get_user_payments_waiting_for_approval.size.should == 1
	# Approve
	up2.approve
	# Test
	u1.get_user_payments_waiting_for_approval.size.should == 0
    end

    it "should have a default hidden flag" do
	object=User.create!(@attr)
	# Test
	object.hidden.should == false
    end

end
