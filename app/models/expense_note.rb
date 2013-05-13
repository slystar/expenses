class ExpenseNote < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :note

    # Relationshipts
    has_many :expenses

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :note, :presence => true
    validates :app_version, :presence => true

    # before save
    before_save :update_version

    # Private methods
    private

    # Method to update version
    def update_version
	# Get current
	current=self.version
	# Update if it's not the creation of original object
	self.version=current + 1
    end
end
