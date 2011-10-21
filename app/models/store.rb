class Store < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :store

    # Relationships
    has_many :expenses

    # Before actions
    before_destroy :verify_expenses

    # Validations
    validates :store, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}

    protected

    # Method to check for expenses
    def verify_expenses
	if self.expenses.size > 0
	    errors.add(:base,"Can't delete store: #{self.store} because it has expenses assigned to it")
	    return false
	else
	    return true
	end
    end
end
