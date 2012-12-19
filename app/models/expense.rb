class Expense < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :date_purchased, :store_id, :pay_method_id, :reason_id, :user_id, :group_id

    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
    belongs_to :reason
    belongs_to :user
    belongs_to :group

    # Validations
    validates :date_purchased, :presence => true, :custom_valid_datetime => true
    validates :store_id, :presence => true
    validates :pay_method_id, :presence => true
    validates :reason_id, :presence => true
    validates :user_id, :presence => true
    validates :group_id, :presence => true
    validates :amount, :presence => true, :numericality => true
    validates_presence_of :store
    validates_presence_of :pay_method
    validates_presence_of :reason
    validates_presence_of :user
    validates_presence_of :group

    # Callbacks
    before_validation(:on => :create) do
	# Check for process_date
	self.errors.add(:base,"Date processed must be nil on create") if not self.process_date.nil?
	# Check for process_flag
	self.errors.add(:base,"Process_flag must be false on create") if self.process_flag

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

    # Check on destruction
    before_destroy :check_for_processed_record

    # Method to process expense
    def process
	# Get group members
	members=group.users
	# Get count of members
	member_count=members.size
	# Get dept amount
	dept_amount=self.amount / member_count.to_f
	# Loop over members
	members.each do |member|
	    # Skip self
	    next if member.id == self.user_id
	    # Create new UserDept
	    ud=UserDept.new()
	    # Add attributes
	    ud.from_user_id=self.user_id
	    ud.to_user_id=member.id
	    ud.amount=dept_amount
	    # Save record
	    ud.save!
	end
	# Update Balance
	UserBalance.update_balances()
	# Set process fields
	self.process_date=Time.now
	self.process_flag=true
	self.save!
    end

    private

    def check_for_processed_record()
	# Set default flag
	if self.process_flag
	    self.errors.add(:base,"Can't delete #{self.class}: because this expense has been processed")
	    return false
	end
	if not self.process_date.nil?
	    self.errors.add(:base,"Can't delete #{self.class}: because this expense has a process date")
	    return false
	end
	# Ok
	return true
    end
end
