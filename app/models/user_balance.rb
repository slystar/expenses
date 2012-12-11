class UserBalance < ActiveRecord::Base
    # Relationships
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    # Custom validation
    validate :check_from_and_to

    # Callbacks
    before_validation(:on => :create) do
	# Check for negative amount
	self.errors.add(:base,"Amount cannot be negative") if not self.amount.nil? and self.amount < 0
    end

    # Methods
    def check_from_and_to
	if from_user_id == to_user_id
	    errors.add(:to_user, "can't be the same as from_user")
	end
    end
end
