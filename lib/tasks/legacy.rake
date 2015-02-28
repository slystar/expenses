#namespace :legacy do
#    # Required libraries
#    require './lib/legacy_migration/legacy_base.rb'
#    require './lib/legacy_migration/required.rb'
#    require 'pry'
#
#    # Set the Rails environment
#    Rails.env='development'
#    # Info
#    puts("Rails env=#{Rails.env}")
#
#    # Variables
#    @times=[]
#    # Start time
#    @times.push(Time.now)
#
#
#    desc 'reset test db'
#    task :reset => :environment do
#	ActiveRecord::Base.record_timestamps = true
#	puts("Rails env (Reset)=#{Rails.env}")
#	# Reset database
#	Rake::Task["db:drop"].invoke
#	Rake::Task["db:create"].invoke
#	# Migrate database
#	Rake::Task["db:migrate"].invoke
#    end
#
#    desc 'prepare test db'
#    task :prepare_test_db => :environment do
#	# Prepare Test database
#	Rake::Task["db:test:prepare"].invoke
#    end
#
#    task :single_validate => :environment do
#	# Generate map
#	expense_map={}
#	# Loop over all Expenses
#	Expense.all.each{|e| expense_map[e.id]=e.id}
#	# Run validation
#	e=LegacyExpense.validate_import(expense_map)
#    end
#
#    task :expense_table_import => :environment do
#	# Variables
#	test_range=0..10
#	# Turn off timestamp to import existing timestamps
#	ActiveRecord::Base.record_timestamps = false
#	# Delete expense
#	Expense.delete_all
#	model=LegacyExpense
#	map={}
#	extra=[]
#	# Print info
#	print("--#{model.name}: ")
#	# Variables
#	count=0
#	displayed_progress=[]
#	# Get all records
#	all=model.all[test_range]
#	# Get total count
#	total_count=all.count
#	# Loop over all
#	all.each do |o|
#	    # Import data
#	    old_id,new_id=o.migrate_me!(*extra)
#	    # Add to map
#	    map[old_id]=new_id
#	    # Calculate progress
#	    progress=(100 * count / total_count)
#	    # Increment count
#	    count += 1
#	    # Display progress
#	    if (progress % 10) == 0 and not displayed_progress.include?(progress)
#		# Print progress
#		print("#{progress}% ")
#		# Add to displayed
#		displayed_progress.push(progress)
#	    end
#	end
#	# Print line return
#	puts()
#	# Test import
#	model.validate_import(map,test_range)
#	# Turn off timestamp to import existing timestamps
#	ActiveRecord::Base.record_timestamps = true
#	
#    end
#
#    task :single_import => :environment do
#	# Turn off timestamp to import existing timestamps
#	ActiveRecord::Base.record_timestamps = false
#	#ActiveRecord::Base.record_timestamps = true
#	# Empty table
#	UserBalance.delete_all
#	# Import balances
#	LegacyUserBalance.migrate_me!
#	# Validate import
#	LegacyUserBalance.validate_import
#	# Turn off timestamp to import existing timestamps
#	ActiveRecord::Base.record_timestamps = true
#    end
#
#    desc 'import legacy data'
#    task :import_data => :environment do
#	# Turn on timestamp (should be default)
#	ActiveRecord::Base.record_timestamps = true
#
#	# Reset database
#	Rake::Task["legacy:reset"].invoke
#
#	# Run time
#	run_time()
#
#	# Turn off timestamp to import existing timestamps
#	ActiveRecord::Base.record_timestamps = false
#
#	# Variables
#	user_map={}
#	group_map={}
#	group_member_map={}
#	pay_method_map={}
#	reason_map={}
#	store_map={}
#	expense_map={}
#	user_payment_map={}
#	user_charge_map={}
#
#	# --------------- USER --------------
#	process_model(LegacyUser, user_map)
#	# --------------- GROUP --------------
#	process_model(LegacyGroup, group_map)
#	# --------------- GROUP_MEMBER --------------
#	process_model(LegacyGroupMember, group_member_map, [user_map,group_map])
#	# -- Get group members
#	group_members={}
#	Group.all.each do |g|
#	    # Get user ids
#	    uids=g.user_ids
#	    # Set hash
#	    group_members[g.id]=uids
#	end
#	# --------------- PAY_METHOD --------------
#	process_model(LegacyPayMethod, pay_method_map)
#	# --------------- REASON --------------
#	process_model(LegacyReason, reason_map)
#	# --------------- STORE --------------
#	process_model(LegacyStore, store_map)
#	# --------------- EXPENSE --------------
#	process_model(LegacyExpense, expense_map, group_members)
#	# --------------- USER_PAYMENT --------------
#	process_model(LegacyUserPayment, user_payment_map)
#	# --------------- USER_CHARGE --------------
#	process_model(LegacyUserCharge, user_charge_map)
#	# --------------- BACKUP --------------
#	# Legacy data not required
#	# --------------- MORTGAGE_PAYMENT --------------
#	file_path=File.join('db','legacy_mortgage_payments.csv')
#	# Copy data
#	LegacyMortgagePayment.migrate_me!(file_path)
#	# Validate copy
#	LegacyMortgagePayment.validate_import(file_path)
#	# --------------- UserBalance --------------
#	# Import balances
#	LegacyUserBalance.migrate_me!
#	# Validate import
#	LegacyUserBalance.validate_import
#
#	# Turn timestamps back on
#	ActiveRecord::Base.record_timestamps = true
#
#	# Prepare test database
#	Rake::Task["legacy:prepare_test_db"].invoke
#    end
#
#    # Method to count records
#    def get_count(model)
#	model.all.count
#    end
#
#    # Method to round
#    def round_to(num, decimals)
#	# Round number
#	((num * 10**decimals).round.to_f / 10**decimals)
#    end
#
#    # Method to get time difference
#    def get_time_diff(time_array)
#	# Get current time
#	now=Time.now
#	# Get start time
#	start=time_array.first
#	# Get last entry
#	last=time_array.last
#	# Round from last
#	diff_from_last=round_to((now - last),2)
#	# Round from start
#	diff_from_start=round_to((now - start),2)
#	# Add to array
#	time_array.push(now)
#	# Get diff
#	return [diff_from_start, diff_from_last]
#    end
#
#    # Method to display run time
#    def run_time()
#	# Get run times
#	from_start,from_last=get_time_diff(@times)
#	puts("    Time: #{from_last} seconds, total: #{from_start}")
#    end
#
#    # Metho to import data
#    def process_model(model,map,extra=[])
#	# Print info
#	print("--#{model.name}: ")
#	# Variables
#	count=0
#	displayed_progress=[]
#	# Get all records
#	all=model.all
#	# Get total count
#	total_count=all.count
#	# Loop over all
#	all.each do |o|
#	    # Import data
#	    old_id,new_id=o.migrate_me!(*extra)
#	    # Add to map
#	    map[old_id]=new_id
#	    # Calculate progress
#	    progress=(100 * count / total_count)
#	    # Increment count
#	    count += 1
#	    # Display progress
#	    if (progress % 10) == 0 and not displayed_progress.include?(progress)
#		# Print progress
#		print("#{progress}% ")
#		# Add to displayed
#		displayed_progress.push(progress)
#	    end
#	end
#	# Print line return
#	puts()
#	# Test import
#	model.validate_import(map)
#	# Run time
#	run_time()
#	# Return map
#	return map
#    end
#end
