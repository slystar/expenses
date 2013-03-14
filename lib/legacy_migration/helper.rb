module LegacyHelper
    # Method to raise error
    def raise_error(field,old,new)
	puts('-' * 10)
	puts("Imported data does not match old data")
	puts("Field: #{field}")
	p old
	p new
	puts('-' * 10)
	raise("Exiting, import failed")
    end
end
