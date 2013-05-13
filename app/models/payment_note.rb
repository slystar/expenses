class PaymentNote < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :user_payment_id, :user_id, :note

    # Relationships
    belongs_to :user_payment
    belongs_to :user

    # Before validations
    before_validation :set_app_version

    # Validations: attributes
    validates :note, :presence => true
    validates :app_version, :presence => true
    # Validations: relationships
    validates :user_payment, :presence => true
    validates :user, :presence => true
end
