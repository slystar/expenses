# Class to pre parse bad bank CSV export files 
# Output:
# Unique ID, Date purchased, Store, Amount
# SHA1,mm/dd/yyyy,Store,80$

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

    # Method to check for valid pre_parser
    def self.valid_pre_parser?(name)
	# Convert to symbole if required
	self.instance_methods.include?(name.to_sym)
    end

    # Test pre_parser
    def test
	# Generate CSV
	csv_string = CSV.generate do |csv|
	    # Add header
	    csv << ["unique_id" ,"date_purchased" ,"store" ,"amount" ,"city" ,"province"]
	    # Loop over content
	    @file_content.each_line do |line|
		# Check line size
		if line.chomp.size < 1
		    # Skip blank lines
		    next
		end
		# Skip header
		next if line =~ /Transaction Date.*Transaction Description.*Amount/
		# Parse line
		csv_array  = line.parse_csv
		# Extract data
		date_purchased=csv_array[0]
		multi_data=csv_array[2].gsub(/\s\s*$/,'')
		amount=csv_array[3]
		# Get missing fields
		unique_id=Digest::SHA1.hexdigest(line.chomp)
		# Split transaction description
		desc=multi_data.split(/\s\s+/)
		# Get store
		store=desc[0]
		city=desc[1]
		prov=desc[2]
		# Fix date
		correct_date_format=date_purchased.gsub('_','/')
		# Get amount number
		number=amount.gsub(/[^0-9.]/,'')
		# Fix amount
		if amount =~ /^-/
		    amount="#{number}$"
		else
		    amount="-#{number}$"
		end
		# Add to output
		csv << [unique_id,correct_date_format,store,amount,city,prov]
	    end
	end
    end

    # Capital One Master Card
    def p_mc_capital_one
	# Generate CSV
	csv_string = CSV.generate do |csv|
	    # Add header
	    csv << ["unique_id" ,"date_purchased" ,"store" ,"amount" ,"city" ,"province"]
	    # Loop over content
	    @file_content.each_line do |line|
		# Check line size
		if line.chomp.size < 1
		    # Skip blank lines
		    next
		end
		# Skip header
		next if line =~ /Transaction Date.*Transaction Description.*Amount/
		# Parse line
		csv_array  = line.parse_csv
		# Extract data
		date_purchased=csv_array[0]
		multi_data=csv_array[2].gsub(/\s\s*$/,'')
		amount=csv_array[3]
		# Get missing fields
		unique_id=Digest::SHA1.hexdigest(line.chomp)
		# Split transaction description
		desc=multi_data.split(/\s\s+/)
		# Get store
		store=desc[0]
		city=desc[1]
		prov=desc[2]
		# Get amount number
		number=amount.gsub(/[^0-9.]/,'')
		# Fix amount
		if amount =~ /^-/
		    amount="#{number}$"
		else
		    amount="-#{number}$"
		end
		# Add to output
		csv << [unique_id,date_purchased,store,amount,city,prov]
	    end
	end
    end
end
