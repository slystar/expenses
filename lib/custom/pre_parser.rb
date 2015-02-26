# Class to pre parse bad bank CSV export files 
# Output:
# Unique ID, Date purchased, Store, Amount

# Required libraries
require 'csv'
require 'digest/sha1'

class PreParser
    # Method to parse data
    def parse(file_content,pre_parser_name)
	# Check if pre_parser exists
	if not self.respond_to?(pre_parser_name.to_sym)
	    raise "Error: pre_parser #{pre_parser_name} does not exist"
	end
	# Prepare data
	@file_content=file_content
	# Call proper pre_parser
	self.__send__(pre_parser_name)
    end

    # Test pre_parser
    def test
	# Generate CSV
	csv_string = CSV.generate do |csv|
	    # Loop over content
	    @file_content.each_line do |line|
		# Check line size
		if line.chomp.size < 1
		    # Skip blank lines
		    next
		end
		p("--#{line}--")
		# Parse line
		p csv_array  = line.parse_csv
		# Extract data
		date_purchased=csv_array[0]
		multi_data=csv_array[2]
		amount=csv_array[3]
		# Get missing fields
		unique_id=Digest::SHA1.hexdigest(date_purchased + multi_data + amount)
		# Get Store
		# Add to output
		#csv << ["row", "of", "CSV", "data"]
	    end
	end
    end
end
