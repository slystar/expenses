class Store < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :store

    # Validations
    validates :store, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
end
