class User < ActiveRecord::Base
    include SharedMethods

    # Options
    has_secure_password

    # Accessible attributes
    attr_accessible :user_name, :password, :password_confirmation, :name

    # Relationshipts
    has_many :group_members, :dependent => :delete_all
    has_many :groups, :through => :group_members
    has_many :expenses
    has_many :user_roles
    has_many :roles, :through => :user_roles
    has_many :user_depts_from, :class_name => 'UserDept', :foreign_key => 'from_user_id'
    has_many :user_depts_to, :class_name => 'UserDept', :foreign_key => 'to_user_id'
    has_many :user_payments_from, :class_name => 'UserPayment', :foreign_key => 'from_user_id'
    has_many :user_payments_to, :class_name => 'UserPayment', :foreign_key => 'to_user_id'
    has_many :user_balances_from, :class_name => 'UserBalance', :foreign_key => 'from_user_id'
    has_many :user_balances_to, :class_name => 'UserBalance', :foreign_key => 'to_user_id'

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :user_name, :presence => true, :uniqueness => {:case_sensitive => false}
    validates :password, :presence => true, :length => {:minimum => 8}
    validates :app_version, :presence => true, :numericality => true

    # Callbacks
    # before_destroy: see observer check_for_expenses_observer.rb
    before_destroy :check_for_expenses_through_groups
    after_destroy :remove_default_group
    after_create :add_user_group, :add_role_to_first_user

    # Method to get user's current depts (what they owe others)
    def depts
	# Get balances where user owes money
	UserBalance.where(:from_user_id => self.id, :current => true).where('amount > ?', 0)
    end

    # Method to get user's current credits (what others owe them)
    def credits
	# Get balances where user owes money
	UserBalance.where(:to_user_id => self.id, :current => true).where('amount > ?', 0)
    end

    # Method to get user's current balances (what they owe others and what others owe them)
    def balances
	# Get balances where user owes money
	UserBalance.where('from_user_id = ?',self.id).where(:current => true).includes(:from_user).includes(:to_user)
    end

    # Method to check if is admin
    def is_admin?
	if roles.detect{|r| r.name =~ /Admin/i}
	    return true
	else
	    return false
	end
    end

    # Below methods are private
    private

    # Method to remove default group
    def remove_default_group
	# Get default group
	default_group=Group.where(:name => self.user_name).first
	# Destroy it
	default_group.destroy
    end

    # Method to check for expenses through groups
    def check_for_expenses_through_groups
	# Get all groups
	groups=self.groups
	# Loop over groups
	groups.each do |group|
	    # Check if group has expenses
	    if group.expenses.size > 0
		self.errors.add(:base,"Can't delete #{self.class}: #{self.name} because it has expenses assigned to it through group '#{group.name}'")
		return false
	    end
	end
    end

    # Method to add a default user group
    def add_user_group
	# Look for user group
	group=Group.where(:name => self.user_name)
	# Check if it exists
	if group.empty?
	    # Create Group
	    group=Group.create!(:name => self.user_name, :description => "Default group for user #{self.user_name}")
	    # Add user to group
	    GroupMember.create!(:user_id => self.id, :group_id => group.id)
	end
    end

    # Method to add the first user to admin role
    def add_role_to_first_user
	# Get count of users
	count=User.all.size
	# Check count
	if count == 1
	    # Add admin role
	    self.roles.create({:name => 'Admin', :description => 'Administrator'})
	end
    end
end
