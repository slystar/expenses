class PaymentNote < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :user_payment_id, :user_id, :note

    # Relationships
    belongs_to :user_payment
    belongs_to :user

    # Validations: attributes
    validates :note, :presence => true
    # Validations: relationships
    validates :user_payment, :presence => true
    validates :user, :presence => true
end
