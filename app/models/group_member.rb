class GroupMember < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :user_id, :group_id

    # Relationshipts
    belongs_to :user
    belongs_to :group

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :user_id, :presence => true
    validates :group_id, :presence => true, :uniqueness => {:scope => :user_id}
    validates :app_version, :presence => true
    validates_presence_of :user
    validates_presence_of :group

    # Callbacks
    before_destroy :check_for_expenses

    private

    # Method to check for expenses
    def check_for_expenses
	# Get group
	group=self.group
	# Check if group has expenses
	if group.expenses.size > 0
	    self.errors.add(:base,"Can't delete #{self.class}: id=#{self.id} because it has expenses assigned to its group '#{group.name}'")
	    return false
	end
    end
end
