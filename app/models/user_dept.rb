class UserDept < ActiveRecord::Base
    # Relationships
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 
    belongs_to :expense

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    validates :expense, :presence => true
    # Custom validation
    validate :check_from_and_to
    validate :check_amount
    validate :check_process_flag, :on => :create

    # Private methods
    private

    # Methods
    def check_from_and_to
	if from_user_id == to_user_id
	    errors.add(:to_user, "can't be the same as from_user")
	end
    end

    # Method to check for a negative amount
    def check_amount
	# Check for negative amount
	self.errors.add(:base,"Amount cannot be negative") if not self.amount.nil? and self.amount < 0
    end

    # Method to check process flag
    def check_process_flag
	# Add error if process_flag is true
	self.errors.add(:base,"Process_flag cannot be set to true on record creation") if self.process_flag == true
    end
end
