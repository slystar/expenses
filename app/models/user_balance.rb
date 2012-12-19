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

    # Callbacks
    before_validation(:on => :create) do
	# Check for negative amount
	self.errors.add(:base,"Amount cannot be negative") if not self.amount.nil? and self.amount < 0
    end

    # Method to update balance
    def self.update_balances
	# Variables
	depts={}
	payments={}
	user_ids=[]
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
	payment_rows=UserPayment.where(:process_flag => false)
	# Calculate payments
	payment_rows.each do |row|
	    # Extract data
	    from_user_id=row.from_user_id
	    to_user_id=row.to_user_id
	    amount=row.amount
	    # Create hash entry for this user
	    payments[from_user_id]={} if payments[from_user_id].nil?
	    payments[to_user_id]={} if payments[to_user_id].nil?
	    depts[from_user_id]={} if depts[from_user_id].nil?
	    depts[to_user_id]={} if depts[to_user_id].nil?
	    # Create to_user hash if it does not exist
	    payments[from_user_id][to_user_id]=0 if payments[from_user_id][to_user_id].nil?
	    payments[to_user_id][from_user_id]=0 if payments[to_user_id][from_user_id].nil?
	    depts[from_user_id][to_user_id]=0 if depts[from_user_id][to_user_id].nil?
	    depts[to_user_id][from_user_id]=0 if depts[to_user_id][from_user_id].nil?
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
		i_owe_them=depts[user_id][other_user_id]
		# They owe me
		they_owe_me=depts[other_user_id][user_id]
		# I paid them
		i_paid_them=payments[user_id][other_user_id]
		# They paid me
		they_paid_me=payments[other_user_id][user_id]
		# Don't forget existing balance
	    end
	end
    end

    # Private methods
    private

    # Methods
    def check_from_and_to
	if from_user_id == to_user_id
	    errors.add(:to_user, "can't be the same as from_user")
	end
    end
end
