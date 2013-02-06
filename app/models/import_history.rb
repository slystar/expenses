class ImportHistory < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :import_config_id, :original_file_name

    # Relationships
    #has_many :expenses

    # Validations
    validates :user_id, :presence => true
    validates :import_config_id, :presence => true

    # Class method to generate new filename
    def self.generate_new_file_name(original_file_name)
	# Get current datetime
	now=Time.now
	# Data to hash
	data="#{now}#{original_file_name}"
	# Calculate hash of original name, can later be changed to file contents
	hash=Digest::MD5.hexdigest(data)
	# Prepare filename
	new_name="#{now.year}_#{now.month}_#{now.day}_#{hash}"
	# Return new name
	return new_name
    end
end
