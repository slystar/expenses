class Group < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name, :description

    # Relationships
    has_many :expenses
    has_many :group_members
    has_many :users, :through => :group_members

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}

    # Callbacks
    before_destroy :check_for_users

    # Method to add user to group
    def add_user(user)
	# Get user groups
	user_groups=user.groups
	# check if user already a member
	if user_groups.detect{|g| g.name == self.name}
	    # Add error
	    self.errors.add(:base,"User #{user.user_name} is already a member of group #{self.name}")
	    # Return value
	    return false
	else
	    # Prepare group_membership attributes
	    attr={:user_id => user.id, :group_id => self.id}
	    # Create a group_membership entry
	    GroupMember.create!(attr)
	    # Return value
	    return true
	end
    end

    # Methods below are private
    private

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
