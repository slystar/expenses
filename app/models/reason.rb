class Reason < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name

    # Relationships
    has_many :expenses

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}

    # Before actions
    before_destroy :verify_expenses

    protected

    # Method to check for expenses
    def verify_expenses
	if self.expenses.size > 0
	    errors.add(:base,"Can't delete store: #{self.name} because it has expenses assigned to it")
	    return false
	else
	    return true
	end
    end
end
