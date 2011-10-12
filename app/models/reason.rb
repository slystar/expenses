class Reason < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :reason

    # Validations
    validates :reason, :presence => true, :uniqueness => true, :length => {:maximum => 50}
end
