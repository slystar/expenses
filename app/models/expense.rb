class Expense < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :date_purchased, :store_id, :pay_method_id, :reason_id, :user_id, :group_id, :amount, :description

    # Virtual attribute
    attr_accessor :add_imported

    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
    belongs_to :reason
    belongs_to :user
    belongs_to :group
    has_many :user_depts
    belongs_to :expense_note

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :date_purchased, :presence => true, :custom_valid_datetime => true
    validates :store_id, :presence => true
    validates :pay_method_id, :presence => true
    validates :reason_id, :presence => true
    validates :user_id, :presence => true
    validates :group_id, :presence => true
    validates :amount, :presence => true, :numericality => true
    validates :app_version, :presence => true
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
    validate :check_duplication_check_processed, :on => :create

    # Before save
    before_save :create_duplication_check_hash

    # Check on destruction
    before_destroy :check_for_processed_record_delete

    # After create
    after_create :process_duplicates

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
		ud.from_user_id=member.id
		ud.to_user_id=self.user_id
		ud.amount=dept_amount
		ud.expense_id=self.id
		# Save record
		ud.save!
	    end
	    # Update Balance
	    UserBalance.update_balances(self.user_id)
	    # Set process fields
	    self.process_date=Time.now
	    self.process_flag=true
	    self.affected_users=members.collect{|u| u.id}.sort.join(',')
	    self.save!
	end
    end

    # Method to find duplicates start from a record
    def find_duplicates
	# Find OTHER records with this hash
	obj=find_duplicate_object.where(:duplication_check_processed => false)
	# If this record is saved in database already
	if self.id
	    obj=obj.where("id != ?", self.id) if obj.count == 1
	end
	# Return obj
	return obj
    end

    # Class method to find all duplicate entries for a user
    def self.find_duplicates(user_id)
	# Find records with same duplication_check_hash
	Expense.where(:duplication_check_hash => 
	    Expense.select(:duplication_check_hash).where(:duplication_check_processed => false)
	    .group(:duplication_check_hash).having("count(duplication_check_hash)>1"))
	.where(:user_id => user_id)
    end

    # Method to review duplicates
    def review_duplicates(note=nil)
	# Get duplicates
	duplicates=find_duplicates
	# Check if note
	if note
	    transaction do
		# Save note
		note.save!
		# Update all records
		duplicates.update_all(:duplication_check_reviewed => true, :duplication_check_processed => true, :duplication_check_reviewed_date => Time.now, :expense_note_id => note.id)
	    end
	else
	    # Update all records
	    duplicates.update_all(:duplication_check_reviewed => true, :duplication_check_processed => true, :duplication_check_reviewed_date => Time.now)
	end
    end

    # Method to prepare find_duplicate object
    def find_duplicate_object
	# Create hash if required
	create_duplication_check_hash if self.duplication_check_hash.nil?
	# Get hash
	d_hash=self.duplication_check_hash
	# Prepare Expense object with basic duplication clause
	Expense.where(:user_id => self.user_id).where(:duplication_check_hash => d_hash)
    end

    # Method to process expenses
    def self.process_all(processing_user_id)
	# Get all unprocessed records
	Expense.where(:process_flag => false).each do |e|
	    # Process this record
	    e.process(processing_user_id)
	end
    end

    # Method to check if this record has been processed
    def processed?
	self.process_flag
    end

    # Private methods
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

    # Method to check duplication_check_processed
    def check_duplication_check_processed
	# Check
	self.errors.add(:duplication_check_processed,"can't be set on creation") if not self.duplication_check_processed == false
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

    # Method to process duplication information
    def process_duplicates
	# Try to find duplicate records (reads can be done in parallel much easier than writes which will lock up databases like spqlite while the write is in progress)
	duplicates=self.find_duplicate_object
	# Check if we need to update records
	if duplicates.size > 1
	    transaction do
		# Update flags
		records_changed=duplicates.update_all(:duplication_check_processed => false)
		# Check if we need to update self
		if records_changed == 0
		    # Set field
		    self.duplication_check_processed=true
		    # Save self
		    self.save
		end
	    end
	end
    end
end
