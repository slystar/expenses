class CheckForExpensesObserver < ActiveRecord::Observer
    # Observe these models
    observe :pay_method, :store, :reason, :group

    # Method to check for expenses
    def before_destroy(object)
	if object.expenses.size > 0
	    object.errors.add(:base,"Can't delete #{object.class}: #{object.name} because it has expenses assigned to it")
	    return false
	else
	    return true
	end
    end
end
