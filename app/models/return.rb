class Return < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :amount, :description, :expense_id, :transaction_date, :user_id

    # Relationships
    belongs_to :expense
    belongs_to :user

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :amount, :presence => true, :numericality => true
    validates :transaction_date, :presence => true, :custom_valid_datetime => true
    validates :user_id, :presence => true
    validates :expense_id, :presence => true
    validates :app_version, :presence => true
    validates_presence_of :expense
    validates_presence_of :user
    # Custom validation
    validate :check_amount
    validate :check_amount_vs_expense
    validate :check_transaction_date

    # Before actions
    # see observer check_for_expenses_observer.rb
    
    # Private methods
    private
    
    # Method to check for a negative amount
    def check_amount
	# Check for negative amount
	self.errors.add(:base,"Amount cannot be negative") if not self.amount.nil? and self.amount < 0
	# Check for more than 2 decimals
	if not self.amount.nil?
	    # Get string sizes
	    amount_float_len=self.amount.to_s.size
	    amount_int_len=self.amount.to_i.to_s.size
	    # Get size difference
	    difference=amount_float_len - amount_int_len
	    # Check for more than 3 characters difference
	    if difference > 3
		self.errors.add(:base,"Amount cannot have more than 2 decimals")
	    end
	end
    end

    # Method to check amount against it's expense
    def check_amount_vs_expense
	# Make sure we have an expense_id
	if not self.expense
	    self.errors.add(:base,"Return must have a valid expense_id")
	    # Return
	    return false
	end
	# Make sure we have an amount
	if self.amount.nil?
	    self.errors.add(:base,"Return must have a valid amount")
	    # Return
	    return false
	end
	# Compare return amount with expense amount
	if self.amount > self.expense.amount
	    self.errors.add(:base,"Return amount cannot be greater than expense amount.")
	end
    end

    # Method to check transaction date
    def check_transaction_date
	# Check if transaction date is older than expense date_purchased
	if self.expense and self.transaction_date and self.transaction_date < self.expense.date_purchased
	    # Add error
	    self.errors.add(:base,"Return transaction date must be equal to or greater than expense purchased date")
	end
    end
end
