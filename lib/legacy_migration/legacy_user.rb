class LegacyUser < LegacyBase
    self.table_name = "users"

    # Method to migrate self
    def migrate_me!
	# Get common data
	name=self.login
	# Crete new User
	new_user=User.new(
	    :user_name => name,
	    :password => 'abcd1234',
	    :name => name,
	)
	# Set timestamps fields
	new_user.created_at = self.created_on
	new_user.updated_at = self.updated_on
	# Validate
	if not new_user.valid?
	    puts("-" * 20)
	    puts("error: #{self.class}->#{self.id}")
	    puts(new_user.errors.messages)
	    puts("Exiting")
	    exit
	end
	# Save record
	new_user.save!
	# Return id map
	return [self.id, new_user.id]
    end

    # Method to test import
    def self.validate_import(record_map)
	# Loop over all old records
	LegacyUser.all.each do |u|
	    # Get first legacy record
	    @old_1=u
	    # Get matching new
	    @new_1=User.find(record_map[u.id])
	    # Test
	    self.raise_error('user_name',@old_1,@new_1) if @new_1.user_name != @old_1.login
	    self.raise_error('name',@old_1,@new_1) if @new_1.name != @old_1.login
	    self.raise_error('created_at',@old_1,@new_1) if @new_1.created_at != @old_1.created_on
	    self.raise_error('updated_at',@old_1,@new_1) if @new_1.updated_at != @old_1.updated_on
	end
	# Test counts
	self.raise_error('counts',@old_1,@new_1) if LegacyUser.all.count != User.all.count
	# Ok
	puts("#{self.name} successfully imported")
	# Return true
	return true
    end
end
