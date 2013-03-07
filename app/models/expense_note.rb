class ExpenseNote < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :note

    # Relationshipts
    has_many :expenses

    # Validations
    validates :note, :presence => true

    # before save
    before_save :update_version

    # Private methods
    private

    # Method to update version
    def update_version
	# Get current
	current=self.version
	# Update if it's not the creation of original object
	self.version=current + 1 if self.id
    end
end
