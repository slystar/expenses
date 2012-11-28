class UserDept < ActiveRecord::Base
    # Relationships
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 

    # Validations
    validates :from_user, :presence => true
end
