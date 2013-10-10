module SpecHelpFunctions
    def get_attr_expense
	# Need these prerequisites
	@store=Store.create!(:name => Faker::Company.name + rand(100).to_s)
	@reason=Reason.create!(:name => Faker::Company.name + rand(100).to_s)
	@pay_method=PayMethod.create!(:name => Faker::Name.name + rand(100).to_s)
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testpass2')
	@group=Group.create!(:name => Faker::Company.name, :description => 'Test group')
	{:date_purchased => Time.now, :store_id=> @store.id, :pay_method_id => @pay_method.id, :reason_id => @reason.id, :user_id => @user.id, :group_id => @group.id, :amount => 10.50}
    end

    # Create a valid expense object
    def get_valid_expense(custom_attr={})
	attr=get_attr_expense.merge(custom_attr)
	e=Expense.create!(attr)
	return e
    end

    # Create a new user
    def get_next_user()
	# Get next user id
	@new_user_id += 1
	# Create user object
	u=User.create!(:user_name => "user#{@new_user_id}", :password => 'testpassuserbalance')
	# Return user object
	return u
    end

    # Add a UserDept entry
    def add_user_dept(u1,u2,amount,expense_id=nil)
	# Create expense if required
	expense_id=get_valid_expense.id if expense_id.nil?
	# Create new UserDept
	ud=UserDept.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=u2.id
	ud.amount=amount
	ud.expense_id=expense_id
	# Save UserDept
	ud.save!
	# Return object
	ud.reload
    end

    # Add and approve a UserPayment entry
    def add_user_payment(u1,u2,amount,approve_flag=true)
	# Create new UserPayment
	up=UserPayment.new()
	# Add attributes
	up.from_user_id=u1.id
	up.to_user_id=u2.id
	up.amount=amount
	# Save UserDept
	up.save!
	# Check for approve flag
	if approve_flag
	    # Approve payment
	    up.approve(up.to_user_id)
	    # Return object
	    up.reload
	end
	# Return object
	return up
    end

    # Add a UserBalance entry
    def add_balance(u1,u2,amount)
	# Get a UserBalance object
	ub=UserBalance.new()
	# Set attributes
	ub.from_user_id=u1.id
	ub.to_user_id=u2.id
	ub.amount=amount
	# Save UserBalance
	ub.save!
	# Return object
	ub.reload
    end

    # Get a valid ImportConfig object
    def get_valid_import_config(attr=@attr)
	# Get an import_config
	ic=ImportConfig.new(attr)
	# Get new user
	u1=get_next_user
	# Get expense attr
	expense_attr=get_attr_expense
	# Add pay_method
	ic.pay_method_id=expense_attr[:pay_method_id]
	# Add user id because it should not be mass assignable
	ic.user_id=u1.id
	# Return object
	return ic
    end

    # Get a valid user object
    def get_valid_new_user()
	User.new({:user_name => 'test', :password => 'testpassword'})
    end

    # Test balance
    def test_balances(u1,u2,amount)
	    # Get most recent UserBalance for u1 to u2
	    ub=UserBalance.where(:from_user_id => u1.id, :to_user_id => u2.id).last
	    # Test: UserBalance amount
	    ub.amount.to_f.round(2).should == amount.to_f.round(2)
	    # Get most recent UserBalance for u2 to u1
	    ub=UserBalance.where(:from_user_id => u2.id, :to_user_id => u1.id).last
	    # Test: UserBalance amount should be inverse
	    ub.amount.to_f.round(2).should == (amount.to_f * -1).round(2)
	    # UserPayments should all be set to processed
	    UserPayment.all.each do |up|
		up.process_flag.should == true
	    end
	    # userDepts should all be set to processed
	    UserDept.all.each do |ud|
		ud.process_flag.should == true
	    end
    end
end
