module SpecHelpFunctions
    def get_attr_expense
	# Need these prerequisites
	@store=Store.create!(:name => Faker::Company.name)
	@reason=Reason.create!(:name => Faker::Company.name)
	@pay_method=PayMethod.create!(:name => Faker::Name.name)
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testpass2')
	@group=Group.create!(:name => Faker::Company.name, :description => 'Test group')
	{:date_purchased => Time.now, :store_id=> @store.id, :pay_method_id => @pay_method.id, :reason_id => @reason.id, :user_id => @user.id, :group_id => @group.id, :amount => 10.50}
    end

    # Create a valid expense object
    def get_valid_expense
	attr=get_attr_expense
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
    def add_user_payment(u1,u2,amount)
	# Create new UserPayment
	ud=UserPayment.new()
	# Add attributes
	ud.from_user_id=u1.id
	ud.to_user_id=u2.id
	ud.amount=amount
	# Save UserDept
	ud.save!
	# Approve payment
	ud.approve
	# Return object
	ud.reload
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
end
