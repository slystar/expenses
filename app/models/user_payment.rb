class UserPayment < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :from_user_id, :to_user_id, :amount

    # Relationships
    has_many :payment_notes
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    # Custom validation
    validate :check_from_and_to
    validate :check_approve_fields
    validate :check_for_negative_amount

    # Callbacks
    before_create :check_approved, :check_approved_date

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
    def check_for_negative_amount
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

    # Method to make sure approved is not set
    def check_approved
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

    # Method to approve this user payment
    def approve
	# Set approved to true
	self.approved=true
	# Set approved_date
	self.approved_date=Time.now
	# Save record
	self.save!
    end
end
