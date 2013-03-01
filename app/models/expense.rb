class Expense < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :date_purchased, :store_id, :pay_method_id, :reason_id, :user_id, :group_id, :amount

    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
    belongs_to :reason
    belongs_to :user
    belongs_to :group
    has_many :user_depts

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
    # Custom validation
    validate :check_amount
    validate :check_process_date, :on => :create
    validate :check_process_flag, :on => :create
    validate :check_for_processed_record_update, :on => :update
    validate :check_duplication_check_reviewed, :on => :create

    # Before save
    before_save :create_duplication_check_hash

    # Check on destruction
    before_destroy :check_for_processed_record_delete

    # Method to process expense
    def process(user_id)
	# Verify user
	if User.where(:id => user_id).first.nil?
	    # Not a valid user, return false
	    return false
	end
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
	    ud.expense_id=self.id
	    # Save record
	    ud.save!
	end
	# Update Balance
	UserBalance.update_balances(user_id)
	# Set process fields
	self.process_date=Time.now
	self.process_flag=true
	self.save!
    end

    # Method to find duplicates start from a record
    def find_duplicates
	# Create hash
	create_duplication_check_hash if self.duplication_check_hash.nil?
	# Get hash
	d_hash=self.duplication_check_hash
	# Find records with this hash
	obj=Expense.where(:user_id => self.user_id).where(:duplication_check_hash => d_hash).where(:duplication_check_reviewed => false)
	# Find possible reviewed duplicates that are now active
	pp Expense.where(:user_id => self.user_id).where(:duplication_check_hash => d_hash).group(:duplication_check_hash,:duplication_check_reviewed).count
	# Add additional check if this is a saved record
	if self.id
	    # Return the equivalent of an empty object if it only found itself
	    return Expense.where('1 == 2') if obj.count == 1
	end
	# Return obj
	return obj
    end

    # Class method to find all duplicate entries for a user
    def self.find_duplicates(user_id)
	# Find records with same duplication_check_hash
	Expense.where(:duplication_check_hash => Expense.select(:duplication_check_hash).group(:duplication_check_hash).having("count(duplication_check_hash) > 1")).where(:user_id => user_id).where(:duplication_check_reviewed => false)
    end

    # Method to review duplicates
    def review_duplicates
	# Get duplicates
	duplicates=find_duplicates
	# Update all records
	duplicates.update_all(:duplication_check_reviewed => true)
    end

    private

    def check_for_processed_record_delete
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

    def check_for_processed_record_update
	# Fields that can be modified
	modifyable_fields=[:store_id, :reason_id, :pay_method_id, :description]
	# Get database version
	db_expense=Expense.find(self.id)
	# Get database process flag
	db_process_flag=db_expense.process_flag
	db_process_date=db_expense.process_date
	# Ok to update if no process info
	if (not db_process_flag) and (db_process_date.nil?)
	    # Good to go
	    return true
	end
	# Loop over attributes
	db_expense.attribute_names.each do |a|
	    # Skip modifyable attributes
	    next if modifyable_fields.include?(a.to_sym)
	    # Check if value has changed
	    if not self[a] == db_expense[a]
		self.errors.add(:base,"Can't update #{self.class} #{a}: because this expense has been processed")
		return false
	    end
	end
    end

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

    # Method to check duplication_check_reviewed
    def check_duplication_check_reviewed
	# Check
	self.errors.add(:duplication_check_reviewed,"can't be set on creation") if not self.duplication_check_reviewed == false
    end

    # Method to create duplication_check_hash
    def create_duplication_check_hash
	# Variable
	string_to_hash=''
	# Add formated date_purchased
	string_to_hash << self.date_purchased.strftime('%Y-%m-%d').to_s
	# Add amount
	string_to_hash << self.amount.to_s
	# Add store_id
	string_to_hash << self.store_id.to_s
	# Create hash
	d_hash=Digest::SHA2.hexdigest(string_to_hash)
	# Set field
	self.duplication_check_hash=d_hash
    end
end
