namespace :legacy do
    # Required libraries
    require './lib/legacy_migration/legacy_base.rb'
    require './lib/legacy_migration/required.rb'
    require 'pry'

    # Set the Rails environment
    Rails.env='development'
    # Info
    puts("Rails env=#{Rails.env}")

    desc 'reset test db'
    task :reset => :environment do
	ActiveRecord::Base.record_timestamps = true
	puts("Rails env (Reset)=#{Rails.env}")
	# Reset database
	Rake::Task["db:drop"].invoke
	Rake::Task["db:create"].invoke
	# Migrate database
	Rake::Task["db:migrate"].invoke
    end

    task :test do
	binding.pry
	o=LegacyUser
	LegacyUser.test
	puts('done')
	o.test
    end

    desc 'import legacy data'
    task :import_data => :environment do

	# Variables
	@times=[]

	# Start time
	@times.push(Time.now)

	# Reset database
	Rake::Task["legacy:reset"].invoke

	# Run time
	run_time()

	# Turn off timestamp to import existing timestamps
	#ActiveRecord::Base.record_timestamps = false

	# Variables
	user_map={}
	group_map={}
	group_member_map={}
	pay_method_map={}
	reason_map={}
	store_map={}
	expense_map={}

	# --------------- USER --------------
	process_model(LegacyUser, user_map)
	# --------------- GROUP --------------
	process_model(LegacyGroup, group_map)
	# --------------- GROUP_MEMBER --------------
	LegacyGroupMember.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!(user_map, group_map)
	    # Add to map
	    group_member_map[old_id]=new_id
	end
	# Test import
	LegacyGroupMember.validate_import(group_member_map)
	# Run time
	run_time()
	# --------------- PAY_METHOD --------------
	process_model(LegacyPayMethod, pay_method_map)
	# --------------- REASON --------------
	process_model(LegacyReason, reason_map)
	# --------------- STORE --------------
	process_model(LegacyStore, store_map)
	# --------------- EXPENSE --------------
	LegacyExpense.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!()
	    # Add to map
	    expense_map[old_id]=new_id
	end
	# Test import
	LegacyExpense.validate_import(expense_map)
	# Run time
	run_time()
	# --------------- USER_CHARGE --------------
	# --------------- USER_PAYMENT --------------
	# --------------- BACKUP --------------
	# --------------- MORTGAGE_PAYMENT --------------

	# --------------- Globat Tests --------------
	# Depts
	# Credits
	# Group members in expenses

	# Turn timestamps back on
	#ActiveRecord::Base.record_timestamps = true
    end

    # Method to count records
    def get_count(model)
	model.all.count
    end

    # Method to round
    def round_to(num, decimals)
	# Round number
	((num * 10**decimals).round.to_f / 10**decimals)
    end

    # Method to get time difference
    def get_time_diff(time_array)
	# Get current time
	now=Time.now
	# Get start time
	start=time_array.first
	# Get last entry
	last=time_array.last
	# Round from last
	diff_from_last=round_to((now - last),2)
	# Round from start
	diff_from_start=round_to((now - start),2)
	# Add to array
	time_array.push(now)
	# Get diff
	return [diff_from_start, diff_from_last]
    end

    # Method to display run time
    def run_time()
	# Get run times
	from_start,from_last=get_time_diff(@times)
	puts("    Time: #{from_last} seconds, total: #{from_start}")
    end

    # Metho to import data
    def process_model(model,map)
	model.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!
	    # Add to map
	    map[old_id]=new_id
	end
	# Test import
	model.validate_import(map)
	# Run time
	run_time()
	# Return map
	return map
    end
end
