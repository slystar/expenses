class UserPayment < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :from_user_id, :to_user_id, :amount

    # Relationships
    has_many :payment_notes
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 
    belongs_to :waiting_on_user, :class_name => 'User' 
    belongs_to :update_balance_history
    belongs_to :return
    accepts_nested_attributes_for :payment_notes

    # Before validations
    before_validation :set_app_version
    before_validation :check_return_id

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    validates :app_version, :presence => true
    # Custom validation
    validate :check_from_and_to
    validate :check_approve_fields
    validate :check_amount
    validate :validate_process_flag, :on => :create

    # Callbacks
    before_create :validate_not_approved, :check_approved_date, :set_waiting_on_user_id
    before_destroy :check_for_approval, :check_process_flag

    # Method to approve this user payment
    def approve(user_id)
	if user_id != self.to_user_id
	    # Error
	    errors.add(:base,"Error: Only to_user can approve user_payments.")
	    # Return
	    return false
	end
	# Set approved to true
	self.approved=true
	# Set approved_date
	self.approved_date=Time.now
	# Save record
	self.save!
    end

    # Method to show visible payment_notes (not deleted)
    def visible_payment_notes
	self.payment_notes.select{|pn| pn.deleted == false}
    end

    # Method to add a return payment (refund)
    def self.return_payment(return_payment_id, from_id, to_id, amount)
	# Create new UserPayment
	up=self.new()
	# Add attributes
	up.from_user_id=from_id
	up.to_user_id=to_id
	up.amount=amount
	up.return_id=return_payment_id
	# Save record
	up.save!
	# Set to approved because it's system doing the payment
	up.approved=true
	# Set approved_date
	up.approved_date=Time.now
	# Save record
	up.save!
	# Return id
	return up.id
    end

    # Private methods
    private

    # Method to make sure from and to are not the same
    def check_from_and_to
	if from_user_id == to_user_id
	    errors.add(:to_user, "can't be the same as from_user")
	end
    end

    # Method to make sure all approved fields are filled in
    def check_approve_fields
	# Get data
	approved_date_blank=approved_date.blank?
	# Make sure both approve fields are set
	if (approved == true and approved_date_blank == true) or (approved != true and not approved_date_blank)
	    errors.add(:base,"All approve fields must be filled")
	end
    end

    # Method to check for a negative amount
    def check_amount
	# Check for negative amount
	self.errors.add(:base,"Amount cannot be negative") if not self.amount.nil? and self.amount < 0
    end

    # Method to make sure approved is not set
    def validate_not_approved
	if self.approved
	    self.errors.add(:base,"Can't create #{self.class}, entry can't be approved on creation")
	    return false
	else
	    return true
	end
    end

    # Method to make sure approved_date is not set
    def check_approved_date
	if not self.approved_date.nil?
	    self.errors.add(:base,"Can't create #{self.class}, entry can't have an approved_date on creation")
	    return false
	else
	    return true
	end
    end

    # Method to check process flag
    def validate_process_flag
	# Add error if process_flag is true
	self.errors.add(:base,"Process_flag cannot be set to true on record creation") if self.process_flag == true
    end

    # Method to check approved
    def check_for_approval
	if self.approved == true
	    self.errors.add(:base,"Can't destroy #{self.class}, it's already been approved")
	    return false
	else
	    return true
	end
    end

    # Method to check process_flag
    def check_process_flag
	if self.process_flag == true
	    self.errors.add(:base,"Can't destroy #{self.class}, it's already been processed")
	    return false
	else
	    return true
	end
    end

    # Method to set initial waiting_on_user_id
    def set_waiting_on_user_id
	self.waiting_on_user_id = self.to_user_id
    end

    # Method to check parent id
    def check_return_id
	# Get return id
	return_id=self.return_id
	# If 0, OK since it is the default
	return true if return_id == 0
	# Check child
	if Return.where(:id => return_id).first
	    return true
	else
	    self.errors.add(:base,"Can't create #{self.class}: because it references a non-existing Return")
	    return false
	end
    end
end
