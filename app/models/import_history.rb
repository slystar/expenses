class ImportHistory < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :import_config_id, :original_file_name

    # Relationships
    belongs_to :import_config
    belongs_to :user

    # Validations
    validates :original_file_name, :presence => true
    # Validations: relationships
    validates :user, :presence => true
    validates :import_config, :presence => true

    # Class method to generate new filename
    def save_file(file_content,target_dir)
	# Check file content
	if file_content.nil? or file_content.empty?
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
	# Return true
	return true
    end
end
