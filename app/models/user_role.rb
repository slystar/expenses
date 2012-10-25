class UserRole < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :user_id, :role_id

    # Relationshipts
    belongs_to :user
    belongs_to :role

    # Validations
    validates :user_id, :presence => true
    validates :role_id, :presence => true, :uniqueness => {:scope => :user_id}
    validates_presence_of :user
    validates_presence_of :role

end
