class Role < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name, :description

    # Relationshipts
    has_many :user_roles
    has_many :users, :through => :user_roles

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
    validates :description, :presence => true

    # Callbacks
    before_destroy :check_for_users

    private

    # Method to check for users
    def check_for_users
	if self.users.size > 0
	    self.errors.add(:base,"Can't delete #{self.class} #{self.name}: because this role has existing users")
	    return false
	else
	    return true
	end
    end
end
