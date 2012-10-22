class Role < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name, :description

    # Relationshipts
    has_many :user_roles
    has_many :users, :through => :user_roles

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
end
