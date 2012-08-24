class CustomValidDateValidator < ActiveModel::EachValidator  
    def validate_each(record, attribute, value)  
	# Check for a valid date
	begin
	    Date.parse(value)
	rescue
	    record.errors[attribute] << "Not a valid date: #{value}"  
	end  
    end  
end  
