class UserBalance < ActiveRecord::Base
    include SharedMethods

    # Accessible attributes (disable mass assignment)
    attr_accessible :created_at

    # Relationships
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 
    belongs_to :update_balance_history

    # Before validations
    before_validation :set_app_version

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    validates :app_version, :presence => true
    # Custom validation
    validate :check_from_and_to
    validate :block_update, :on => :update

    # Callbacks
    before_validation :check_for_duplicate, :mark_current
    after_save :create_opposite_record, :update_current

    # Method to update balance
    def self.update_balances(user_id)
	# Verify user
	if User.where(:id => user_id).first.nil?
	    # Not a valid user, return false
	    return false
	end
	# Variables
	depts={}
	payments={}
	balances={}
	user_ids=[]
	pre_finals={}
	records_to_save=[]
	old_user_balances={}
	# Get all UserDept
	dept_rows=UserDept.where(:process_flag => false)
	# Calculate depts
	dept_rows.each do |row|
	    # Extract data
	    from_user_id=row.from_user_id
	    to_user_id=row.to_user_id
	    amount=row.amount
	    # Create hash entry for this user
	    depts[from_user_id]={} if depts[from_user_id].nil?
	    depts[to_user_id]={} if depts[to_user_id].nil?
	    payments[from_user_id]={} if payments[from_user_id].nil?
	    payments[to_user_id]={} if payments[to_user_id].nil?
	    # Create to_user hash if it does not exist
	    depts[from_user_id][to_user_id]=0 if depts[from_user_id][to_user_id].nil?
	    depts[to_user_id][from_user_id]=0 if depts[to_user_id][from_user_id].nil?
	    payments[from_user_id][to_user_id]=0 if payments[from_user_id][to_user_id].nil?
	    payments[to_user_id][from_user_id]=0 if payments[to_user_id][from_user_id].nil?
	    # Add to total
	    depts[from_user_id][to_user_id] += amount
	    # Keep user_ids
	    user_ids.push(from_user_id) if not user_ids.include?(from_user_id)
	    user_ids.push(to_user_id) if not user_ids.include?(to_user_id)
	end
	# Get all Payments
	payment_rows=UserPayment.where(:process_flag => false, :approved=> true)
	# Calculate payments
	payment_rows.each do |row|
	    # Extract data
	    from_user_id=row.from_user_id
	    to_user_id=row.to_user_id
	    amount=row.amount
	    # Create hash entry for this user
	    depts[from_user_id]={} if depts[from_user_id].nil?
	    depts[to_user_id]={} if depts[to_user_id].nil?
	    payments[from_user_id]={} if payments[from_user_id].nil?
	    payments[to_user_id]={} if payments[to_user_id].nil?
	    # Create to_user hash if it does not exist
	    depts[from_user_id][to_user_id]=0 if depts[from_user_id][to_user_id].nil?
	    depts[to_user_id][from_user_id]=0 if depts[to_user_id][from_user_id].nil?
	    payments[from_user_id][to_user_id]=0 if payments[from_user_id][to_user_id].nil?
	    payments[to_user_id][from_user_id]=0 if payments[to_user_id][from_user_id].nil?
	    # Add to total
	    payments[from_user_id][to_user_id] += amount
	    # Keep user_ids
	    user_ids.push(from_user_id) if not user_ids.include?(from_user_id)
	    user_ids.push(to_user_id) if not user_ids.include?(to_user_id)
	end
	# Get current blance
	balance_rows=UserBalance.where(:current => true)
	# Calculate balances
	balance_rows.each do |row|
	    # Extract data
	    from_user_id=row.from_user_id
	    to_user_id=row.to_user_id
	    amount=row.amount
	    # Create hash entry for this user
	    balances[from_user_id]={} if balances[from_user_id].nil?
	    # Add to balances
	    balances[from_user_id][to_user_id]=amount
	end
	# Loop over user_ids
	user_ids.each do |user_id|
	    # Get other user_ids
	    other_user_ids=user_ids - [user_id]
	    # Loop over other_user_ids
	    other_user_ids.each do |other_user_id|
		# I owe them
		i_owe_them=depts[user_id][other_user_id].to_f
		# They owe me
		they_owe_me=depts[other_user_id][user_id].to_f
		# I paid them
		i_paid_them=payments[user_id][other_user_id].to_f
		# They paid me
		they_paid_me=payments[other_user_id][user_id].to_f
		# Current balance
		if balances[user_id].nil? or balances[user_id][other_user_id].nil?
		    current_balance=0
		else
		    current_balance=balances[user_id][other_user_id]
		end
		# Calculate totals
		total_i_owe_them=i_owe_them - i_paid_them
		total_they_owe_me=they_owe_me - they_paid_me
		# Resulting global value
		pre_final_balance=total_i_owe_them - total_they_owe_me + current_balance
		# Add to records to save
		records_to_save.push([user_id,other_user_id,pre_final_balance])
	    end
	end
	# Get new UpdateBalanceHistory
	ubh=UpdateBalanceHistory.create!(:user_id => user_id)
	# Loop over records to save
	records_to_save.each do |row|
	    # Get fields
	    from_user_id=row[0]
	    to_user_id=row[1]
	    # Get a UserBalance object
	    ub=UserBalance.new()
	    # Set attributes
	    ub.from_user_id=from_user_id
	    ub.to_user_id=to_user_id
	    ub.amount=row[2]
	    ub.current=true
	    # Check if record available for from_user_id
	    if not old_user_balances[from_user_id].nil?
		# Get old balance
		old_ub=old_user_balances[from_user_id][to_user_id]
		# Check if record available
		if not old_ub.nil?
		    # Update balance
		    ub.previous_user_balance_id=old_ub.id
		end
	    end
	    # Save UserBalance
	    if ub.save
		# Update process_flags
		UserPayment.where(:process_flag => false, :approved=> true).update_all(process_flag: true, update_balance_history_id: ubh.id)
		UserDept.where(:process_flag => false).update_all(process_flag: true, update_balance_history_id: ubh.id)
		# Set old balances to not current
		UserBalance.where('id != ?',ub.id).where(:from_user_id => from_user_id, :to_user_id => to_user_id, :current => true).update_all(current: false, update_balance_history_id: ubh.id)
		# Set UpdateBalanceHistory
		UserBalance.where('id != ?',ub.id).where(:from_user_id => from_user_id, :to_user_id => to_user_id, :current => false).update_all(update_balance_history_id: ubh.id)
	    end
	end
	# Return true
	return true
    end

    # Method to check for duplicate
    def has_current_duplicate?
	# Try to find a current balance with same amount
	dup=UserBalance.where(:current => true, :from_user_id => self.from_user_id, :to_user_id => self.to_user_id, :amount => self.amount).first
	# Check
	if dup.nil?
	    return false
	else
	    return true
	end
    end

    # Private methods
    private

    # Check to and from fields
    def check_from_and_to
	if from_user_id == to_user_id
	    errors.add(:to_user, "can't be the same as from_user")
	end
    end

    # Method to set current
    def mark_current
	self.current=true
    end

    # Method to create reverse balance
    def create_opposite_record
	# Check if we need to create reverse balance
	if self.reverse_balance_id == 0
	    # Create reverse balance
	    ub=UserBalance.new()
	    ub.from_user_id=self.to_user_id
	    ub.to_user_id=self.from_user_id
	    ub.amount=(self.amount * -1)
	    ub.reverse_balance_id=self.id
	    # Save record
	    ub.save!
	    # Update self
	    self.update_attributes(:reverse_balance_id => ub.id)
	end
    end

    # Method to mark current balances
    def update_current
	# Update old balances
	UserBalance.where(:from_user_id => self.from_user_id, :to_user_id => self.to_user_id).where(:current => true).where("id not in (?)",[self.id]).update_all(:current => false)
    end

    # Method to block update
    def block_update
	# Exception
	exceptions=['reverse_balance_id']
	# Loop over changed attribute names
	self.changed.each do |name|
	    # Skip exceptions
	    next if exceptions.include?(name)
	    # Add error
	    self.errors.add(name.to_sym, "updating is not allowed")
	    # Return false, change found
	    return false
	end
    end

    # Method to check for duplicate balance
    def check_for_duplicate
	# Check
	if self.has_current_duplicate?
	    self.errors.add(:base, "can't create duplicate current balance")
	    return false
	else
	    return true
	end
    end
end
