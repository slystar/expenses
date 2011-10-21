class Reason < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
end
