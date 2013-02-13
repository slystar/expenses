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
    validates :expense_id, :presence => true
    # Validations: relationships
    validates :user, :presence => true

    # Method to import data
    def import(file, import_config)
	# Get file type
	file_type=import_config.file_type.downcase
	# Import based on filetype
	case file_type
	when 'csv'
	    import_csv(file,import_config)
	else
	    # Unknown import filetype
	    self.errors.add(:base,"Unknown import filetype: #{file_type}")
	    # Return nil
	    return false
	end
	# Success
	return true
    end
end
