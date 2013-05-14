class LegacyGroup < LegacyBase
    self.table_name = 'groups'

    # Method to migrate self
    def migrate_me!
	# Some groups are auto-created by User class, look for one
	existing_group=Group.find(:first, :conditions => [ "lower(name) =?", self.group_name.downcase])
	# check existing group
	if existing_group.nil?
	    # Crete new Object
	    new_group=Group.new(
		:name => self.group_name,
		:display_order => self.display_order
	    )
	    # Set id
	    new_group.id=self.id
	else
	    new_group=existing_group
	end
	# Set display order
	new_group.display_order=self.display_order
	# Set timestamps fields
	new_group.created_at = self.created_on
	new_group.updated_at = self.updated_on
	# Make sure updated_ad is not null
	if new_group.updated_at.nil?
	    # Set updated_at = created_at
	    new_group.updated_at=new_group.created_at
	end
	# Validate
	if not new_group.valid?
	    puts("-" * 20)
	    puts("error: #{self.class}->#{self.id}")
	    puts(new_group.errors.messages)
	    exit
	end
	# Set app version
	new_group.app_version=get_app_version
	# Save record
	new_group.save!
	# Return id map
	return [self.id, new_group.id]
    end

    # Method to test import
    def self.validate_import(record_map)
	# Get all
	all=LegacyGroup.all
	# Loop over all old records
	all.each do |o|
	    # Get first legacy record
	    old_1=o
	    # Get matching new
	    new_1=Group.find(record_map[o.id])
	    # Test
	    self.raise_error('name',old_1,new_1) if new_1.name.downcase != old_1.group_name.downcase
	    self.raise_error('display_order',old_1,new_1) if new_1.display_order != old_1.display_order
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('app_version',old_1,new_1) if new_1.app_version != get_app_version
	    if new_1.updated_at != old_1.updated_on 
		if new_1.updated_at != old_1.created_on
		    self.raise_error('updated_at',old_1,new_1)
		end
	    end
	end
	# Test counts
	self.raise_error('counts',old_1,new_1) if all.count != Group.all.count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end
end
