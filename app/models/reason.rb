class Reason < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :reason

    # Validations
    validates :reason, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
end
