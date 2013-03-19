class LegacyGroupMember < LegacyBase
    self.table_name = 'group_members'

    # Method to migrate self
    def migrate_me!(user_map, group_map)
	# Get new information
	new_user_id=user_map[self.user_id]
	new_group_id=group_map[self.group_id]
	# Ignore if user_id does not exist
	if new_user_id.nil?
	    # Skip
	    puts("Skipping group_member user_id: #{self.user_id}")
	    # next
	    return nil
	end
	# Some group_memberships are auto-created by User class, look for one
	existing_group_membership=GroupMember.find(:first, :conditions => {:user_id => new_user_id, :group_id => new_group_id})
	# check existing group
	if existing_group_membership.nil?
	    # Crete new Object
	    new_group=GroupMember.new(
	    )
	else
	    new_group=existing_group_membership
	end
	# Set fields
	new_group.user_id = new_user_id
	new_group.group_id = new_group_id
	# Set timestamps fields
	new_group.created_at = self.created_on
	new_group.updated_at = self.updated_on
	# Validate
	if not new_group.valid?
	    puts("-" * 20)
	    puts("error: #{self.class}-> GroupMember : #{self.id}")
	    puts(new_group.errors.messages)
	    exit
	end
	# Save record
	new_group.save!
	# Return id map
	return [self.id, new_group.id]
    end

    # Method to test import
    def self.validate_import(record_map)
	# Variables
	skipped=0
	# Loop over all old records
	LegacyGroupMember.all.each do |o|
	    # Skip records that have been skipped
	    if not record_map.keys.include?(o.id)
		# Add to counter
		skipped += 1
		# Next record
		next
	    end
	    # Get GroupMember records
	    old_1=o
	    new_1=GroupMember.find(record_map[o.id])
	    # Get User records
	    old_user=LegacyUser.find(old_1.user_id)
	    new_user=User.find(new_1.user_id)
	    # Get Group records
	    old_group=LegacyGroup.find(old_1.group_id)
	    new_group=Group.find(new_1.group_id)
	    # Test
	    self.raise_error('user',old_1,new_1) if new_user.user_name != old_user.login
	    self.raise_error('group',old_1,new_1) if new_group.name.downcase != old_group.group_name.downcase
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('updated_at',old_1,new_1) if new_1.updated_at != old_1.updated_on
	end
	self.raise_error('counts',@old_1,@new_1) if (LegacyGroupMember.all.count - skipped) != GroupMember.all.count
	# Ok
	puts("#{self.name} successfully imported")
	# Return true
	return true
    end
end
