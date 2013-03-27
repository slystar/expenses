class LegacyUserPayment < LegacyBase
    self.table_name = 'user_payments'

    # Method to migrate self
    def migrate_me!
	# Get notes
	notes=self.notes
	reply_notes=self.reply_notes
	# Create new Object
	new_object=UserPayment.new(
	    :from_user_id => self.from_user_id,
	    :to_user_id => self.to_user_id,
	    :amount => self.amount
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
	# Set process info
	if self.approved
	    new_object.approved = self.approved
	    new_object.approved_date =  self.approved_date
	    new_object.process_flag =  true
	    new_object.process_date = self.approved_date
	else
	    new_object.approved = false
	    new_object.process_flag =  false
	end
	# Check for notes
	if not notes.empty?
	    # Create new note
	    note=PaymentNote.new(
		:user_payment_id => self.id,
		:user_id => self.from_user_id, 
		:note => self.notes
	    )
	    # Set timestamps fields
	    note.created_at = self.created_on
	    note.updated_at = self.updated_on
	    # Validate
	    if not note.valid?
		p self
		p note
		p note.errors.messages
		raise("Invalid note")
	    end
	    # Save note
	    note.save!
	end
	# Check for reply notes
	if not reply_notes.empty?
	    # Create new note
	    note=PaymentNote.new(
		:user_payment_id => self.id,
		:user_id => self.from_user_id, 
		:note => self.reply_notes
	    )
	    # Set timestamps fields
	    note.created_at = self.created_on
	    note.updated_at = self.updated_on
	    # Validate
	    if not note.valid?
		p self
		p note
		p note.errors.messages
		raise("Invalid note")
	    end
	    # Save note
	    note.save!
	end
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
	all=LegacyUserPayment.all
	# Loop over all old records
	all.each do |u|
	    # Get first legacy record
	    old_1=u
	    # Get matching new
	    new_1=UserPayment.find(record_map[u.id])
	    # Get notes
	    notes=old_1.notes
	    reply_notes=old_1.reply_notes
	    # Test
	    self.raise_error('id',old_1,new_1) if new_1.id != old_1.id
	    self.raise_error('from_user_id',old_1,new_1) if new_1.from_user_id != old_1.from_user_id
	    self.raise_error('to_user_id',old_1,new_1) if new_1.to_user_id != old_1.to_user_id
	    self.raise_error('amount',old_1,new_1) if new_1.amount != old_1.amount
	    self.raise_error('created_at',old_1,new_1) if new_1.created_at != old_1.created_on
	    self.raise_error('approved',old_1,new_1) if new_1.approved != old_1.approved
	    self.raise_error('approved_date',old_1,new_1) if new_1.approved_date.strftime(strftime_string) != old_1.approved_date.strftime(strftime_string)
	    self.raise_error('process_flag',old_1,new_1) if new_1.process_flag != old_1.approved
	    if u.approved
		self.raise_error('process_date',old_1,new_1) if new_1.process_date.strftime(strftime_string) != old_1.approved_date.strftime(strftime_string)
	    end
	    self.raise_error('updated_at',old_1,new_1) if new_1.updated_at != old_1.updated_on
	    if not notes.empty?
		# Get notes
		new_note=PaymentNote.find(:first,:conditions => {:user_payment_id => old_1.id})
		# Test
		self.raise_error('notes',old_1,new_1) if new_note.note != notes
	    end
	    if not reply_notes.empty?
		# Get notes
		new_note=PaymentNote.find(:last,:conditions => {:user_payment_id => old_1.id})
		# Test
		self.raise_error('reply notes',old_1,new_1) if new_note.note != reply_notes
	    end
	end
	# Test counts
	self.raise_error('counts',old_1,new_1) if all.count != UserPayment.all.count
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end
end
