class LegacyMortgagePayment < LegacyBase
    self.table_name = 'mortgage_payments'

    # Method to migrate self
    def self.migrate_me!(file_path)
	# Required library
	require 'csv'
	# Get headers
	headers=self.column_names
	# Generate csv
	CSV.open(file_path, "w") do |csv|
	    # Add headers
	    csv << headers
	    # Loop over all instances
	    self.all.each do |m|
		# Prepare blank array
		arr=[]
		# Loop over header
		headers.each do |h|
		    # Add this value
		    arr << m[h]
		end
		# Add array to csv
		csv << arr
	    end
	end
    end

    # Method to test import
    def self.validate_import(file_path)
	# Get all records
	all=self.all
	# Make sure the file exist
	raise "File not found: #{file_path}" if not File.exist?(file_path)
	# Get line count
	file_line_count = File.foreach(file_path).inject(0) {|c, line| c+1}
	# Get database count
	db_row_count=all.count
	# compare (remove header)
	raise "Counts do not match for #{self.name}" if (file_line_count - 1) != db_row_count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end
end
