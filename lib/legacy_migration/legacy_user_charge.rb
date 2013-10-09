class LegacyUserCharge < LegacyBase
    self.table_name = 'user_charges'

    # Method to migrate self
    def migrate_me!
	# Create new Object
	new_object=UserDept.new(
	    :from_user_id => self.from_user_id,
	    :to_user_id => self.to_user_id,
	    :amount => self.amount
	)
	# Get dummy expense record
	dummy_expense=create_or_get_dummy_expense
	# Set expense
	new_object.expense_id = dummy_expense.id
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
	    p self
	    p new_object
	    puts("Exiting")
	    exit
	end
	new_object.app_version=get_app_version
	# Save record
	new_object.save!
	# Set remaining fields
	new_object.process_flag =  true
	new_object.process_date = self.updated_on
	# Save record
	new_object.save!
	# Return id map
	return [self.id, new_object.id]
    end

    # Method to test import
    def self.validate_import(record_map)
	# Variables
	strftime_string="%Y-%m-%d"
	# Get all
	all=LegacyUserCharge.all
	# Loop over all old records
	all.each do |u|
	    # Get first legacy record
	    old_1=u
	    # Get matching new
	    new_1=UserDept.find(record_map[u.id])
	    # Test
	    self.raise_error('id',old_1,new_1) if new_1.id != old_1.id
	    self.raise_error('from_user_id',old_1,new_1) if new_1.from_user_id != old_1.from_user_id
	    self.raise_error('to_user_id',old_1,new_1) if new_1.to_user_id != old_1.to_user_id
	    self.raise_error('amount',old_1,new_1) if new_1.amount != old_1.amount
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('updated_at',old_1,new_1) if new_1.updated_at != old_1.updated_on
	    self.raise_error('process_flag',old_1,new_1) if new_1.process_flag != true
	    self.raise_error('process_date',old_1,new_1) if new_1.process_date.strftime(strftime_string) != old_1.updated_on.strftime(strftime_string)
	    self.raise_error('app_version',old_1,new_1) if new_1.app_version != get_app_version
	end
	# Test counts
	self.raise_error('counts',old_1,new_1) if all.count != UserDept.all.count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end

    # Method to get or create dummy expense
    def create_or_get_dummy_expense()
	# Variables
	legacy_label='Legacy'
	# Try to find dummy records
	dummy_reason=Reason.find(:first,:conditions => {:name => legacy_label})
	# Check if we found a result
	if dummy_reason
	    # Get Dummy Expense
	    rec=Expense.find(:first,:conditions => {:reason_id => dummy_reason.id})
	else
	    # Get current timestamp setting
	    current_timestamp_setting=ActiveRecord::Base.record_timestamps
	    # Turn on timestamp because User creates groups and group_membershipts
	    ActiveRecord::Base.record_timestamps = true
	    # Variables
	    d=Date.parse('1980-01-01')
	    now=Time.now
	    pay_method=PayMethod.create!(:name => legacy_label)
	    reason=Reason.create!(:name => legacy_label)
	    store=Store.create!(:name => legacy_label)
	    user=User.create!(:user_name => legacy_label, :password => 'legacyimportdata',:hidden => true)
	    group=Group.find(:first, :conditions => {:name => legacy_label})
	    # Create new Object
	    new_object=Expense.new(
		:date_purchased => d,
		:description => "Dummy expense created for legacy import of user_charges (user_dept)",
		:pay_method_id => pay_method.id,
		:reason_id => reason.id,
		:store_id => store.id,
		:user_id => user.id,
		:group_id => group.id,
		:amount => 0
	    )
	    # Set timestamps fields
	    new_object.created_at = now
	    new_object.updated_at = now
	    # Save Expense
	    new_object.save!
	    # Set new object
	    rec=new_object.reload
	    # Turn timestamp back to previous setting
	    ActiveRecord::Base.record_timestamps = current_timestamp_setting
	end
	# Return expense record
	return rec
    end
end
