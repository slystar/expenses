module SpecHelpFunctions
    def get_attr_expense
	# Need these prerequisites
	@store=Store.create!(:name => Faker::Company.name)
	@reason=Reason.create!(:name => 'TV')
	@pay_method=PayMethod.create!(:name => 'cash')
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testpass2')
	@group=Group.create!(:name => Faker::Company.name, :description => 'Test group')
	{:date_purchased => Time.now, :store_id=> @store, :pay_method_id => @pay_method, :reason_id => @reason, :user_id => @user, :group_id => @group}
    end

    # Create a valid expense object
    def get_valid_expense
	attr=get_attr_expense
	e=Expense.create!(attr)
	return e
    end
end
