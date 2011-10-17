class PayMethod < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :pay_method

    # Validations
    validates :pay_method, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
end
