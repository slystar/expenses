class ImportDatum < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :unique_id, :unique_hash, :mapped_fields, :expense_id

    # Relationships
    belongs_to :user
    belongs_to :import_config
    belongs_to :import_history

    # Validations
    validates :unique_hash, :presence => true
    validates :mapped_fields, :presence => true
    # Validations: relationships
    validates :user, :presence => true
end
