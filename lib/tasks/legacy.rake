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
	times=[]

	# Start time
	times.push(Time.now)

	# Reset database
	Rake::Task["legacy:reset"].invoke

	# Run time
	run_time(times)

	# Turn off timestamp to import existing timestamps
	#ActiveRecord::Base.record_timestamps = false

	# Variables
	user_map={}
	group_map={}
	group_member_map={}
	pay_method_map={}
	reason_map={}
	store_map={}

	# --------------- USER --------------
	LegacyUser.all.each do |u|
	    # Import user
	    old_id,new_id=u.migrate_me!
	    # Add to map
	    user_map[old_id]=new_id
	end
	# Test import
	LegacyUser.validate_import(user_map)
	# Run time
	run_time(times)
	# --------------- GROUP --------------
	LegacyGroup.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!
	    # Add to map
	    group_map[old_id]=new_id
	end
	# Test import
	LegacyGroup.validate_import(group_map)
	# Run time
	run_time(times)
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
	run_time(times)
	# --------------- PAY_METHOD --------------
	LegacyPayMethod.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!()
	    # Add to map
	    pay_method_map[old_id]=new_id
	end
	# Test import
	LegacyPayMethod.validate_import(pay_method_map)
	# Run time
	run_time(times)
	# --------------- REASON --------------
	LegacyReason.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!()
	    # Add to map
	    reason_map[old_id]=new_id
	end
	# Test import
	LegacyReason.validate_import(reason_map)
	# Run time
	run_time(times)
	# --------------- STORE --------------
	LegacyStore.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!()
	    # Add to map
	    store_map[old_id]=new_id
	end
	# Test import
	LegacyStore.validate_import(store_map)
	# Run time
	run_time(times)
	# --------------- EXPENSE --------------
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

    # Method to get time difference
    def get_time_diff(time_array)
	# Get current time
	now=Time.now
	# Get last entry
	last=time_array.last
	# Round
	diff=((now - last) * 100).to_i / 100.00
	# Get diff
	return diff
    end

    # Method to display run time
    def run_time(times)
	puts("    Time: #{get_time_diff(times)} seconds")
    end
end
