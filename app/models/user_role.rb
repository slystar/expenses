class UserRole < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :user_id, :role_id

    # Relationshipts
    belongs_to :user
    belongs_to :role
end
