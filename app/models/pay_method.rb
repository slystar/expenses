class PayMethod < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :name

    # Relationships
    has_many :expenses

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}

    # Before actions
    # see observer check_for_expenses_observer.rb
end
