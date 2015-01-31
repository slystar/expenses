class PaymentNote < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :user_payment_id, :user_id, :note

    # Relationships
    belongs_to :user_payment
    belongs_to :user

    # Before validations
    before_validation :set_app_version

    # Validations: attributes
    validates :note, :presence => true
    validates :app_version, :presence => true
    # Validations: relationships
    validates :user_payment, :presence => true
    validates :user, :presence => true

    # Callbacks
    before_destroy :check_for_approval, :check_for_other_user

    # Method to know if can be destroyed
    def can_be_destroyed?(user)
	# Check note user
	if user.id != self.user_id
	    return false
	end
	# Check user_payment user
	if self.user_payment.from_user_id != user.id
	    return false
	end
	# Check for other notes
	if has_other_user_after?
	    return false
	end
	# OK
	return true
    end

    # Method to delete note without destroying note
    def delete_note
	# set deleted flag
	self.deleted=true
	# Save
	if self.save
	    return true
	else
	    return false
	end
    end

    private

    # Method to check approved
    def check_for_approval
	if self.user_payment.approved == true
	    self.errors.add(:base,"Can't destroy #{self.class}, user_payment has already been approved")
	    return false
	else
	    return true
	end
    end

    # Method to check for other user
    def has_other_user_after?
	# Get all payment_notes for this user_payment
	notes=self.user_payment.payment_notes
	# Loop over notes
	notes.each do |note|
	    # Skip previous notes
	    next if note.id < self.id
	    # Look for other users notes following this one
	    if note.user_id != self.user_id
		return true
	    end
	end
	# No other user after
	return false
    end

    # Method to check for other user
    def check_for_other_user
	if has_other_user_after?
	    self.errors.add(:base,"Can't destroy #{self.class}, there is a note from another user after this one.")
	    return false
	else
	    return true
	end
    end
end
