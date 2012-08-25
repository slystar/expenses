module SpecHelpFunctions
    def get_attr_expense
	{:date_purchased => Time.now, :store_id=> 1, :pay_method_id => 1, :reason_id => 1, :user_id => 1, :group_id => 1}
    end

    # Create a valid expense object
    def get_valid_expense
	@store=Store.create(:name => Faker::Company.name)
	@reason=Reason.create(:name => 'TV')
	@pay_method=PayMethod.create(:name => 'cash')
	attr={:date_purchased => Time.now, :store_id => @store.id, :pay_method_id => @pay_method.id, :reason_id => @reason.id, :user_id => 1, :group_id => 1}
	return Expense.create(attr)
    end
end
