# This class represents a virtual table in the legacy system to complement an existing table in the new system
# It is also known as a tableless model
class LegacyUserBalance
    # Required to create a virtual model that behaves like a normal model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    # List attributes since they cannot be read from database
    #attr_accessor :name, :email, :content

    # Needs to have it's own create method since there is not database backend
    def initialize(attributes = {})
	attributes.each do |name, value|
	    send("#{name}=", value)
	end
    end

    # Make sure rails knows there is no table for this model
    def persisted?
	false
    end

    # Method to migrate self
    def self.migrate_me!
	# Get users
	users=User.all
	# Track Done
	done={}
	# Loop over users
	users.each do |u|
	    # This balance calculation code was taken from the old system and tweaked slightly for new naming conventions
	    #--Set up balances
	    this_user=u
	    users=User.find(:all,:conditions => ["id<>?",this_user.id])
	    @users={}
	    users.each {|user| @users[user.id]=user.user_name}
	    #--Calculate charges for minus charges against
	    user_charges_data=LegacyUserCharge.find_by_sql("select from_user_id,to_user_id,sum(amount) as amount from user_charges where from_user_id=#{this_user.id} or to_user_id=#{this_user.id} group by from_user_id,to_user_id")
	    user_charges_all=[]
	    user_charges_data.each do |row|
		user_charges_all[row.from_user_id]=[] if user_charges_all[row.from_user_id].nil?
		user_charges_all[row.from_user_id][row.to_user_id]=row.amount
	    end
	    #--calculate payments for minus payments against
	    user_payments_data=LegacyUserPayment.find_by_sql("select from_user_id,to_user_id,sum(amount) as amount from user_payments where (from_user_id=#{this_user.id} or to_user_id=#{this_user.id}) and approved=1 group by from_user_id,to_user_id")
	    user_payments_all=[]
	    user_payments_data.each do |row|
		user_payments_all[row.from_user_id]=[] if user_payments_all[row.from_user_id].nil?
		user_payments_all[row.from_user_id][row.to_user_id]=row.amount
	    end
	    #--Calculate total overall difference between charges and payments
	    @diff={}
	    users.each do |user|
		i_owe_them=(user_charges_all[this_user.id].nil? or user_charges_all[this_user.id][user.id].nil?) ? 0 : user_charges_all[this_user.id][user.id]
		they_owe_me=(user_charges_all[user.id].nil? or user_charges_all[user.id][this_user.id].nil?) ? 0 : user_charges_all[user.id][this_user.id]
		i_paid_them=(user_payments_all[this_user.id].nil? or user_payments_all[this_user.id][user.id].nil?) ? 0 : user_payments_all[this_user.id][user.id]
		they_paid_me=(user_payments_all[user.id].nil? or user_payments_all[user.id][this_user.id].nil?) ? 0 : user_payments_all[user.id][this_user.id]
		@diff[user.id]=(i_owe_them-they_owe_me)-(i_paid_them-they_paid_me)
	    end
	    # Loop over balances
	    @diff.each do |to_user_id, balance|
		# Skip done, code already creates reverse entry
		if not done[to_user_id].nil?
		    if done[to_user_id][u.id]==-balance
			# Skip
			puts("Skip reverse record to:#{to_user_id}, from:#{u.id}, balance: #{balance}")
			next
		    end
		end
		# Create a balance if required
		if balance != 0
		    # No methods are mass assignable
		    ub=UserBalance.new()
		    # Add attributes
		    ub.from_user_id=u.id
		    ub.to_user_id=to_user_id
		    ub.amount=balance
		    ub.created_at=Time.now
		    ub.updated_at=Time.now
		    ub.current=true
		    ub.app_version=get_app_version
		    # Save record
		    ub.save!
		end
		# Keep track of done
		done[u.id]={} if done[u.id].nil?
		done[u.id][to_user_id]=balance
		# Add
		puts("Add record to:#{to_user_id}, from:#{u.id}, balance: #{balance}")
	    end
	end
    end

    # Method to test import
    def self.validate_import()
	# Get all records
	all=UserBalance.all
	# Get count
	count=all.count
	# There should be at least 2 balance entries
	raise("There should be at least 2 balances, there are currently: #{count}") if count < 2
	# There should be oposite balances for each user
	all.each do |ub|
	    # Find oposite record
	    opposite=UserBalance.find(:all,:conditions => {:from_user_id=>ub.to_user_id,:to_user_id=>ub.from_user_id,:current => true})
	    # Check size
	    raise("Error: opposite should not have more than 1 record") if opposite.size > 1
	    # Check app_version
	    raise("Error: app_version should be 1") if ub.app_version != get_app_version
	    # Get record
	    opposite_rec=opposite.first
	    # Test
	    if opposite_rec.amount !=(ub.amount * -1)
		p ub
		p opposite_rec
		raise("No opposite blance for id: #{ub.id}")
	    end
	end
	# Ok
	puts("#{self.name} (#{all.count}) successfully imported")
	# Return true
	return true
    end
end
