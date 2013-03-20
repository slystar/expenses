class LegacyPayMethod < LegacyBase
    self.table_name = 'pay_methods'

    # Method to migrate self
    def migrate_me!
	# Create new Object
	new_object=PayMethod.new(
	    :name => self.pay_method
	)
	# Set timestamps fields
	new_object.created_at = self.created_on
	new_object.updated_at = self.updated_on
	# Set id
	new_object.id=self.id
	# Validate
	if not new_object.valid?
	    puts("-" * 20)
	    puts("error: #{self.class}->#{self.id}")
	    puts(new_object.errors.messages)
	    puts("Exiting")
	    exit
	end
	# Save record
	new_object.save!
	# Return id map
	return [self.id, new_object.id]
    end

    # Method to test import
    def self.validate_import(record_map)
	# Get all
	all=LegacyPayMethod.all
	# Loop over all old records
	all.each do |u|
	    # Get first legacy record
	    old_1=u
	    # Get matching new
	    new_1=PayMethod.find(record_map[u.id])
	    # Test
	    self.raise_error('name',old_1,new_1) if new_1.name != old_1.pay_method
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('updated_at',old_1,new_1) if new_1.updated_at != old_1.updated_on
	end
	# Test counts
	self.raise_error('counts',old_1,new_1) if all.count != PayMethod.all.count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end
end
