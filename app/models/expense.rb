class Expense < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :date_purchased, :store_id, :pay_method_id, :reason_id, :user_id, :group_id

    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
    belongs_to :reason
    belongs_to :user

    # Validations
    validates :date_purchased, :presence => true, :custom_valid_datetime => true
    validates :store_id, :presence => true
    validates :pay_method_id, :presence => true
    validates :reason_id, :presence => true
    validates :user_id, :presence => true
    validates :group_id, :presence => true
    validates_presence_of :store
    validates_presence_of :pay_method
    validates_presence_of :reason
    validates_presence_of :user
end
