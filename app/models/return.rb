class Return < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :amount, :description, :expense_id, :transaction_date, :user_id

    # Relationships
    belongs_to :expense
    belongs_to :user
    has_many :user_payments

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
    validate :check_process_date, :on => :create
    validate :check_process_flag, :on => :create

    # Check on destruction
    before_destroy :check_for_processed_record_delete

    # Before actions
    # see observer check_for_expenses_observer.rb
    
    # Method to process expense
    def process(processing_user_id)
	# Verify user
	if User.where(:id => processing_user_id).first.nil?
	    # Not a valid user, return false
	    return false
	end
	# Add transaction
	transaction do
	    # Get group members
	    members=self.expense.group.users
	    # Get count of members
	    member_count=members.size
	    # Get return amount
	    return_amount=self.amount / member_count.to_f
	    # Loop over members
	    members.each do |member|
		# Skip self
		next if member.id == self.user_id
		# Create new UserPayment
		UserPayment.return_payment(self.id, member.id, self.user_id, return_amount)
	    end
	    # Update Balance
	    UserBalance.update_balances(self.user_id)
	    # Set process fields
	    self.process_date=Time.now
	    self.process_flag=true
	    self.save!
	end
    end
    
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
    
    # Method to check process_date
    def check_process_date
	# Check for process_date
	self.errors.add(:base,"Date processed must be nil on create") if not self.process_date.nil?
    end

    # Method to check process_flag
    def check_process_flag
	# Check for process_flag
	self.errors.add(:base,"Process_flag must be false on create") if self.process_flag
    end

    # Method to check if this record can be deleted
    def check_for_processed_record_delete
	# Set default flag
	if self.process_flag
	    self.errors.add(:base,"Can't delete #{self.class}: because this return has been processed")
	    return false
	end
	if not self.process_date.nil?
	    self.errors.add(:base,"Can't delete #{self.class}: because this return has a process date")
	    return false
	end
	# Ok
	return true
    end
end
