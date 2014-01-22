class ImportHistory < ActiveRecord::Base
    require 'csv'

    include SharedMethods

    # Accessible attributes
    attr_accessible :import_config_id, :original_file_name

    # Virtual attributes
    attr_accessor :import_accepted, :import_rejected, :file_empty, :target_dir

    # Relationships
    belongs_to :import_config
    belongs_to :user

    # Before validations
    before_validation :set_app_version
    before_save :check_new_file_name

    # Validations
    validates :original_file_name, :presence => true
    validates :app_version, :presence => true
    # Validations: relationships
    validates :user, :presence => true
    validates :import_config, :presence => true

    # method to generate new filename
    def save_file(file_content,target_dir)
	# Set default file_empty
	self.file_empty=true
	# Check file content
	if file_content.nil? or file_content.empty?
	    # Add error
	    self.errors.add(:base,"File cannot be empty")
	    return nil
	end
	# Get current datetime
	now=Time.now
	# Data to hash
	data=file_content
	# Calculate hash of original name, can later be changed to file contents
	hash=Digest::SHA2.hexdigest(data)
	# Prepare filename
	new_name="#{now.year}_#{now.strftime('%m')}_#{now.strftime('%d')}_#{hash}"
	# Set new file path
	new_file_path=File.join(target_dir, new_name)
	# Save data to file
	begin
	    File.open(new_file_path, 'w'){|fin| fin.print(file_content)}
	rescue => e
	    # Error
	    raise e
	end
	# Set new name
	self.new_file_name=new_name
	# Set flag
	self.file_empty=false
	# Set target dir
	self.target_dir=target_dir
	# Return true
	return true
    end

    # Method to remove saved file
    def remove_saved_file
	# Check if we have a target_dir
	if not self.target_dir.nil?
	    # Get full path
	    full_path=File.join(self.target_dir,new_file_name)
	    # Remove file
	    if File.delete(full_path)
		# Return true
		return true
	    else
		return false
	    end
	elsif self.new_file_name.nil?
	    # No file was saved to start with
	    return true
	else
	    # Raise error, maybe this should be saved in database
	    raise "No value in virtual attribute target_dir"
	    # Return false
	    return false
	end
    end

    # Method to create field digest
    def create_digest(data)
	Digest::SHA2.hexdigest(data)
    end

    # Method to import data
    def import_data(file, import_config,user_id)
	# Get file type
	file_type=import_config.file_type.downcase
	# Check if file exists
	if File.exist?(file)
	    # Read file
	    file_content=File.read(file)
	    # Import based on filetype
	    case file_type
	    when 'csv'
		import_csv(file_content,import_config,user_id)
	    else
		# Unknown import filetype
		self.errors.add(:base,"Unknown import filetype: #{file_type}")
		# Return nil
		return false
	    end
	    # Save file
	    self.save_file(file_content, Rails.configuration.upload_path)
	    # Success
	    return true
	else
	    # Unknown import filetype
	    self.errors.add(:base,"File does not exist: #{file}")
	    # Return nil
	    return false
	end
    end

    # Private methods
    private

    # Method to check the amount
    def amount_positive(amount)
	# Remove dollar sign
	new_amount=amount.gsub('$','')
	# Remove whitesapces
	new_amount.gsub!(/\s/,'')
	# Check for non numeric characters
	if new_amount =~ /[^0-9.-]/
	    return false
	end
	# Convert to integer
	amount_int=new_amount.to_i
	# Check if positive
	if amount_int >= 0
	    return true
	else
	    return false
	end
    end

    # Method to clean amount
    def clean_amount(amount)
	# Keep only digits and decimal point
	return amount.gsub(/[^0-9.]/,'')
    end

    # Method to import CSV data
    def import_csv(file_content, import_config, user_id)
	# Variables
	self.import_accepted=[]
	self.import_rejected=[]
	line_count=0
	# Get unique hash fields
	unique_hash_ids=import_config[:unique_id_hash_fields]
	# Clean file
	file_content.gsub!(/ ,/,',')
	file_content.gsub!(/, /,',')
	# Loop over csv
	CSV.parse(file_content) do |row|
	    # Variables
	    unique_hash_str=''
	    mapped_fields={}
	    records_to_import=[]
	    # Increment line count
	    line_count += 1
	    # Get unique id column
	    unique_id_col=import_config[:unique_id_field].to_i if not import_config[:unique_id_field].nil?
	    # Collect fields for unique_hash
	    unique_hash_ids.each{|id| unique_hash_str << row[id]}
	    # Get attributes
	    unique_id=row[unique_id_col]
	    unique_hash=create_digest(unique_hash_str)
	    # Recreate new mapped_fields with proper values
	    import_config[:field_mapping].each{|column, row_id| mapped_fields[column]=row[row_id]}
	    # Extract amount
	    amount=mapped_fields[:amount]
	    # Extract date_purchased
	    date_purchased=mapped_fields[:date_purchased]
	    # Check amount
	    if not amount_positive(amount)
		# Add to rejected
		add_import_info(line_count,row,"Positive amount")
		# Skip negative amounts since those are payments
		next
	    end
	    # Clean amount
	    mapped_fields[:amount]=clean_amount(amount)
	    # Create date object if available
	    if date_purchased
		if import_config[:date_type]==0
		    # So far, all dates are in mm/day/yyyy
		    date_array=date_purchased.match(/(\d\d)\/(\d\d)\/(\d\d\d\d)/)
		    # Get info
		    d=date_array[2]
		    m=date_array[1]
		    y=date_array[3]
		    # Create new date string
		    new_date_str="#{y}-#{m}-#{d}"
		    # Convert to date object
		    date_obj=Date.parse(new_date_str)
		    # Save date object
		    mapped_fields[:date_purchased]=date_obj
		else
		    # Raise error
		    raise 'Unsupported date_type for this import_config record'
		end
	    end
	    # Set attributes
	    attr={:unique_id => unique_hash, :unique_hash => unique_hash, :mapped_fields => mapped_fields}
	    # Create new ImportData
	    id=ImportDatum.new(attr)
	    # Set user
	    id.user_id=user_id
	    # Set import_history_id
	    id.import_history_id=self.id
	    # Set import_config_id
	    id.import_config_id=import_config.id
	    # check if record is valid
	    if id.valid?
		# Save record
		if id.save
		    # Keep track
		    add_import_info(line_count,row)
		else
		    # Keep track
		    add_import_info(line_count,row,"Error creating ImportData: #{id.errors.messages}")
		end
	    else
		# Look for duplicate entry.
		dup=ImportDatum.where(:unique_hash => id.unique_hash).where(:user_id => user_id).find(:first)
		# Check duplicate
		if not dup.nil?
		    # Keep track
		    add_import_info(line_count,row,"Record already imported on #{dup.created_at} -- #{dup.to_yaml} -- #{id.to_yaml}")
		else
		    # Add row info
		    err_msg="ID: #{unique_hash},"
		    # Prepare message
		    err_msg << id.errors.messages.to_s
		    # Not valid, add to errors
		    self.errors.add(:base,err_msg)
		    # Keep track
		    add_import_info(line_count,row,"Error: invalid ImportData: #{id.errors.messages} -- #{id.to_yaml}")
		end
	    end
	end
    end

    # Method to keep track of imported rows
    def add_import_info(line_num,file_row,msg=nil)
	# Check for accepted row
	if msg.nil?
	    self.import_accepted.push([line_num,file_row,'OK'])
	else
	    self.import_rejected.push([line_num,file_row,msg])
	end
    end

    # Method to check new file name
    def check_new_file_name
	# Check attribute
	if self.file_empty
	    # add error
	    self.errors.add(:base,"No file content was imported, possibly due to missing or empty import file")
	    # return false
	    return false
	end
    end
end
