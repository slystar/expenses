class Expense < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :date_purchased, :store_id, :pay_method_id, :reason_id, :user_id, :group_id

    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
    belongs_to :reason
    belongs_to :user

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

    # Callbacks
    before_validation(:on => :create) do
	# Check for process_date
	self.errors.add(:base,"Date processed must be nil on create") if not self.process_date.nil?
	# Check for process_flag
	self.errors.add(:base,"Process_flag must be false on create") if self.process_flag
    end

    # Check on destruction
    before_destroy :check_for_processed_record

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
