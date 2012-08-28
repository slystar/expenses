class Group < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name, :description

    # Relationships
    has_many :expenses

    # Validations
    validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 50}
end
