class Return < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :amount, :description, :expense_id, :transaction_date, :user_id

    # Relationships
    has_many :expenses

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :amount, :presence => true, :numericality => true
    validates :transaction_date, :presence => true, :custom_valid_datetime => true
    validates :user_id, :presence => true
    validates :expense_id, :presence => true
    validates :app_version, :presence => true

    # Before actions
    # see observer check_for_expenses_observer.rb
end
