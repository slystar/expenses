class UpdateBalanceHistory < ActiveRecord::Base
    # Relationships
    has_many :user_balances
    has_many :user_depts
    has_many :user_payments
    belongs_to :user

    # Validations
    validates :user_id, :presence => true
end
