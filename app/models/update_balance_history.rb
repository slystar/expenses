class UpdateBalanceHistory < ActiveRecord::Base
    include SharedMethods

    # Relationships
    has_many :user_balances
    has_many :user_depts
    has_many :user_payments
    belongs_to :user

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :user_id, :presence => true
    validates :app_version, :presence => true
end
