class UserBalance < ActiveRecord::Base
    # Relationships
    belongs_to :from_user, :class_name => 'User'
    belongs_to :to_user, :class_name => 'User' 

    # Validations
    validates :from_user, :presence => true
    validates :to_user, :presence => true
    validates :amount, :presence => true, :numericality => true
    # Custom validation
    validate :check_from_and_to

    # Method to update balance
    def self.update_balances
	# Variables
	depts={}
	payments={}
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
		# Calculate totals
		total_i_owe_them=i_owe_them - i_paid_them
		total_they_owe_me=they_owe_me - they_paid_me
		# Resulting global value
		pre_final_balance=total_i_owe_them - total_they_owe_me
		# Prepare hash for this user
		pre_finals[user_id]={} if pre_finals[user_id].nil?
		# Check if an entry needs to be created
		if pre_final_balance > 0
		    pre_finals[user_id][other_user_id]=pre_final_balance
		else
		    pre_finals[user_id][other_user_id]=0
		end
	    end
	end
	# Loop over pre_finals
	pre_finals.each do |user_id, hash|
	    # Loop over hash
	    hash.each do |other_user_id, amount|
		i_owe_them=pre_finals[user_id][other_user_id].to_f
		they_owe_me=pre_finals[other_user_id][user_id].to_f
		total_owe=i_owe_them - they_owe_me
		# Get Current balance to
		current_balance_to=UserBalance.where(:from_user_id => user_id, :to_user_id => other_user_id).last
		# Prepare amount
		if current_balance_to.nil?
		    balance_amount_to=0
		else
		    balance_amount_to=current_balance_to.amount.to_f
		    # Create hash entry if it does not exist
		    old_user_balances[user_id]={} if old_user_balances[user_id].nil?
		    # Keep track of UserBalances that need to be updated
		    old_user_balances[user_id][other_user_id]=current_balance_to
		end
		# Get Current balance from
		current_balance_from=UserBalance.where(:from_user_id => other_user_id, :to_user_id => user_id).last
		# Prepare amount
		if current_balance_from.nil?
		    balance_amount_from=0
		else
		    balance_amount_from=current_balance_from.amount.to_f
		    # Create hash entry if it does not exist
		    old_user_balances[other_user_id]={} if old_user_balances[other_user_id].nil?
		    # Keep track of UserBalances that need to be updated
		    old_user_balances[other_user_id][user_id]=current_balance_from
		end
		# Get total balance
		total_balance=balance_amount_to - balance_amount_from
		# Calculate overall total
		overall_total=total_owe + total_balance
		# Check if overall_total is not 0
		if overall_total != 0
		    # Keep track of records to save
		    records_to_save.push([user_id,other_user_id,overall_total])
		end
	    end
	end
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
		UserPayment.where(:process_flag => false, :approved=> true).update_all(process_flag: true)
		UserDept.where(:process_flag => false).update_all(process_flag: true)
		# Set old balances to not current
		UserBalance.where('id != ?',ub.id).where(:from_user_id => from_user_id, :to_user_id => to_user_id, :current => true).update_all(current: false)
	    end
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
end
