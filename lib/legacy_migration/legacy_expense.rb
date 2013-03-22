class LegacyExpense < LegacyBase
    self.table_name = 'expenses'

    # Method to migrate self
    def migrate_me!
	# BAD records fix
	bad_records={}
	# Add fixes for bad records
	bad_records[154]={:store_id => 288}
	bad_records[184]={:store_id => 291}
	bad_records[300]={:store_id => 241}
	bad_records[346]={:store_id => 241}
	# Create new Object
	new_object=Expense.new(
	    :date_purchased => self.date_bought,
	    :description => self.description ,
	    :pay_method_id => self.pay_method_id,
	    :reason_id => self.reason_id,
	    :store_id => self.store_id,
	    :user_id => self.user_id,
	    :group_id => self.group_id,
	    :amount => self.amount,
	    :process_date => self.process_date,
	    :process_flag => self.process_flag
	)
	# Set timestamps fields
	new_object.created_at = self.created_on
	new_object.updated_at = self.updated_on
	# Set id
	new_object.id=self.id
	# Apply fix if required
	if bad_records.keys.include?(self.id)
	    # Loop over bad keys
	    bad_records[self.id].each do |field, value|
		# Apply fix
		new_object[field]=value
	    end
	end
	# Apply fix for missing group (seems to be group sophie or personal for sophie based on record analysis)
	if self.group_id == 4
	    # Get legacy group
	    g=Group.find(:first,:conditions => {:name => new_object.user.name})
	    # Set group_id
	    new_object.group_id=g.id
	    # Info
	    puts("  Expense: #{self.id} set group_id = #{new_object.group.name}")
	end
	# Validate
	if not new_object.valid?
	    puts("-" * 20)
	    puts("error: #{self.class}->#{self.id}")
	    puts(new_object.errors.messages)
	    puts
	    p self
	    p new_object
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
	# Variables
	reasons={}
	pay_methods={}
	stores={}
	users={}
	groups={}
	# Get all reasons
	LegacyReason.select(:id).select(:reason).all.each{|o| reasons[o.id]=o.reason}
	# Get all pay_methods
	LegacyPayMethod.select(:id).select(:pay_method).all.each{|o| reasons[o.id]=o.pay_method}
	# Get all stores
	LegacyStore.select(:id).select(:store).all.each{|o| reasons[o.id]=o.store}
	# Get all users
	LegacyUser.select(:id).select(:login).all.each{|o| users[o.id]=o.login}
	# Get all groups
	LegacyGroup.select(:id).select(:group_name).all.each{|o| groups[o.id]=o.group_name}
	# Get all
	all=LegacyExpense.all
	# Loop over all old records
	all.each do |u|
	    # Get first legacy record
	    old_1=u
	    # Get matching new
	    new_1=Expense.find(record_map[u.id])
	    # Get charged users
	    charged_users=u.charged_users
	    # Test
	    self.raise_error('id',old_1,new_1) if new_1.id != old_1.id
	    self.raise_error('date_purchased',old_1,new_1) if new_1.date_purchased != old_1.date_purchased
	    self.raise_error('description',old_1,new_1) if new_1.description != old_1.description
	    self.raise_error('pay_method',old_1,new_1) if new_1.pay_method != pay_methods[old_1.pay_method_id]
	    self.raise_error('reason',old_1,new_1) if new_1.reason.name != reasons[old_1.reason_id]
	    self.raise_error('store',old_1,new_1) if new_1.store.name != stores[old_1.store_id]
	    self.raise_error('user',old_1,new_1) if new_1.user.user_name != users[old_1.user_id]
	    self.raise_error('group',old_1,new_1) if new_1.group.name != groups[old_1.group_id]
	    self.raise_error('amount',old_1,new_1) if new_1.amount != old_1.amount
	    self.raise_error('process_date',old_1,new_1) if new_1.process_date != old_1.process_date
	    self.raise_error('process_flag',old_1,new_1) if new_1.process_flag != old_1.process_date
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('updated_at',old_1,new_1) if new_1.updated_at != old_1.updated_on
	    # Check if charged users
	    if charged_users
		# Get charged user ids
		charged_user_ids=charged_users.split(' | ').first.split(',').sort
		# Get new records charged user ids
		new_charged_user_ids=new_1.group.users.select{|o| o.id}.sort
		# Test
		self.raise_error('charged_users',old_1,new_1) if new_charged_users_ids != charged_users_ids
	    end
	end
	# Test counts
	self.raise_error('counts',old_1,new_1) if all.count != Expense.all.count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end

    # Method to get legacy_group
    def get_or_create_legacy_group()
	# Variables
	group_name='legacy'
	# Try to find legacy group
	g=Group.find(:first,:conditions => {:name => group_name})
	# If no group found
	if g.nil?
	    # Create group
	    g=Group.new({:name => group_name})
	    # Save group
	    g.save!
	    # Loop over all users
	    User.all.each do |u|
		# Add members
		g.users << u
	    end
	    # Save group
	    g.save!
	end
	# Return group
	return g
    end
end
