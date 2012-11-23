class UserPayment < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :from_user_id, :to_user_id, :amount

    # Relationships
    has_many :payment_notes

    # Validations
    validates :from_user_id, :presence => true
    validates :to_user_id, :presence => true
    validates :amount, :presence => true, :numericality => true
end
