class Store < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :name

    # Relationships
    has_many :expenses
    has_many :children, :class_name => "Store", :foreign_key => "parent_id"
    belongs_to :parent, :class_name => "Store", :foreign_key => "parent_id"

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
    validates :app_version, :presence => true

    # Before actions
    # see observer check_for_expenses_observer.rb
    
    # Before filter
    before_destroy :check_if_parent
    before_validation :check_parent_id

    private

    # Method to check parent id
    def check_parent_id
	# Get parent id
	parent_id=self.parent_id
	# If 0, OK
	return true if parent_id == 0
	# Check child
	if Store.where(:id => parent_id).first
	    return true
	else
	    self.errors.add(:base,"Can't create #{self.class} #{self.name}: because it references a non-existing #{self.class}")
	    return false
	end
    end

    # Method to check if parent
    def check_if_parent
	if self.children.size > 0
	    self.errors.add(:base,"Can't delete #{self.class} #{self.name}: because this store has children")
	    return false
	else
	    return true
	end
    end
end
