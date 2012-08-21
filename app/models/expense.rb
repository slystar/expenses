class Expense < ActiveRecord::Base
    # Relationshipts
    belongs_to :store
    belongs_to :pay_method
end
