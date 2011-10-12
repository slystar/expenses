class Store < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :store

    # Validations
    validates :store, :presence => true, :uniqueness => true, :length => {:maximum => 50}
end
