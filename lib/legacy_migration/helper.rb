module LegacyHelper
    # Method to raise error
    def raise_error(field,old,new,bind_with_pry=false)
	puts('-' * 10)
	puts("Imported data does not match old data")
	puts("Field: #{field}")
	p old
	p new
	puts('-' * 10)
	# Bind with pry to debug if required
	if bind_with_pry
	    binding.pry
	end
	# Raise error
	raise("Exiting, import failed")
    end

    # Method to get app_version
    def get_app_version
	return 1
    end
end
