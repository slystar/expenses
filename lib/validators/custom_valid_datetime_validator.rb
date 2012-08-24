class CustomValidDatetimeValidator < ActiveModel::EachValidator  
    def validate_each(record, attribute, value)  
	# Check for a valid date
	begin
	    Date.parse(value.to_s)
	    DateTime.parse(value.to_s)
	rescue
	    record.errors[attribute] << "Not a valid datetime: #{value}"  
	end  
    end  
end  
