class ImportConfig < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes
    attr_accessible :title, :description, :field_mapping, :file_type, :unique_id_field, :unique_id_hash_fields, :date_type

    # Serialize
    serialize :field_mapping
    serialize :unique_id_hash_fields

    # Constants
    FILE_TYPES=['csv']
    DATE_TYPES=['mm/day/yyyy']

    # Relationships
    belongs_to :user

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :title, :presence => true
    validates :description, :presence => true
    validates :field_mapping, :presence => true
    validates :file_type, :presence => true
    validates :unique_id_field, :presence => true
    validates :unique_id_hash_fields, :presence => true
    validates :date_type, :presence => true
    validates :app_version, :presence => true
    # Validations: relationships
    validates :user, :presence => true
    # Validations: Custom
    validate :check_field_mapping_type
    validate :check_file_type
    validate :check_unique_id_hash_fields
    validate :check_date_type

    private

    # Method to check the type of field_mapping
    def check_field_mapping_type
	self.errors.add(:field_mapping,"should be a hash") if not self.field_mapping.is_a?(Hash)
    end

    # Method to check the file_type, make sure it's supported
    def check_file_type
	self.errors.add(:file_type,"not among supported file types: #{FILE_TYPES.join(',')}") if not self.file_type.nil? and not FILE_TYPES.include?(self.file_type.downcase)
    end

    # Method to check the type of unique_id_hash_fields
    def check_unique_id_hash_fields
	self.errors.add(:unique_id_hash_fields,"should be an array") if not self.unique_id_hash_fields.is_a?(Array)
    end

    # Method to check the date_type, make sure it's supported
    def check_date_type
	self.errors.add(:date_type,"not among supported date types: #{DATE_TYPES.join(',')}") if not self.date_type.nil? and DATE_TYPES[self.date_type].nil?
    end
end
