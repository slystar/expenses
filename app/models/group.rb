class Group < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name, :description

    # Relationships
    has_many :expenses
    has_many :group_members
    has_many :users, :through => :group_members

    # Validations
    validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 50}

    # Callbacks
    before_destroy :keep_all_group, :check_for_users

    private

    # Method to keep all group
    def keep_all_group
	if self.name == 'ALL'
	    self.errors.add(:base,"Can't delete #{self.class} #{self.name}: because this group is the default group")
	    return false
	else
	    return true
	end
    end

    # Method to check for users
    def check_for_users
	if self.users.size > 0
	    self.errors.add(:base,"Can't delete #{self.class} #{self.name}: because this group has existing users")
	    return false
	else
	    return true
	end
    end
end
