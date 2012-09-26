class User < ActiveRecord::Base
    # Options
    has_secure_password

    # Accessible attributes
    attr_accessible :user_name, :password, :password_confirmation

    # Relationshipts
    has_many :group_members
    has_many :groups, :through => :group_members
    has_many :expenses

    # Validations
    validates :user_name, :presence => true, :uniqueness => true
    validates :password, :presence => true, :length => {:minimum => 8}

    # Callbacks
    # before_destroy: see observer check_for_expenses_observer.rb
    after_create :check_for_default_group, :add_user_group

    private

    # Method to check for the default groups
    def check_for_default_group()
	# Get all group
	all=Group.where(:name => 'ALL')
	# Check if it exists
	if all.empty?
	    # Create Group
	    Group.create!(:name => 'ALL', :description => 'Default ALL group')
	end
    end

    #Method to add a default user group
    def add_user_group
	# Get all group
	all=Group.where(:name => 'ALL').first
	# Add to all group
	GroupMember.create!(:user_id => self.id, :group_id => all.id)
	# Look for user group
	group=Group.where(:name => self.user_name)
	# Check if it exists
	if group.empty?
	    # Create Group
	    group=Group.create!(:name => self.user_name, :description => "Default group for user #{self.user_name}")
	    # Add user to group
	    GroupMember.create!(:user_id => self, :group_id => group.id)
	end
    end
end
