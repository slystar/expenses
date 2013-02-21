class ImportDatum < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :unique_id, :unique_hash, :mapped_fields, :expense_id

    # Serialize
    serialize :mapped_fields

    # Relationships
    belongs_to :user
    belongs_to :import_config
    belongs_to :import_history

    # Validations
    validates :unique_id, :uniqueness => true
    validates :unique_hash, :presence => true, :uniqueness => true
    validates :mapped_fields, :presence => true
    # Validations: relationships
    validates :user, :presence => true
    validates :import_history, :presence => true
    validates :import_config, :presence => true
    # Validations: Custom
    validate :check_mapped_fields_type
    validate :check_expense_id_on_create, :on => :create
    validate :check_process_flag_on_create, :on => :create
    validate :check_process_date_on_create, :on => :create

    # Method to get a list of import records to process
    def self.imports_to_process(user_id)
	# Find records that have not been processed for this user
	recs=ImportDatum.where(:user_id => user_id).where(:process_flag => false)
	# Get records
	return recs.all
    end

    private

    # Method to check the type of field_mapping
    def check_mapped_fields_type
	self.errors.add(:mapped_fields,"should be a hash") if not self.mapped_fields.is_a?(Hash)
    end

    # Method to check expense_id on record creation
    def check_expense_id_on_create
	self.errors.add(:expense_id,"should not be set on creation") if not self.expense_id.nil?
    end

    # Method to check process_flag on record creation
    def check_process_flag_on_create
	self.errors.add(:process_flag,"should not be set on creation") if not self.process_flag == false
    end

    # Method to check process_date on record creation
    def check_process_date_on_create
	self.errors.add(:process_date,"should not be set on creation") if not self.process_date.nil?
    end
end
