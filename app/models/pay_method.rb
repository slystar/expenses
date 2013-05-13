class PayMethod < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :name

    # Relationships
    has_many :expenses

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 50}
    validates :app_version, :presence => true

    # Before actions
    # see observer check_for_expenses_observer.rb
end
