namespace :legacy do
    # Required libraries
    require './lib/legacy_migration/legacy_base.rb'
    require './lib/legacy_migration/legacy_user.rb'
    require './lib/legacy_migration/legacy_group.rb'
    require 'pry'

    namespace :test do
	# Set the Rails environment
	Rails.env='test'
	# Info
	puts("Rails env=#{Rails.env}")

	desc 'import legacy data into test'
	task :import => :environment do
	    # Reset database
	    Rake::Task["db:reset"].invoke
	    # Import legacy data
	    Rake::Task["legacy:import_data"].invoke
	    # Reset database
	    #Rake::Task["db:reset"].invoke
	end

	desc 'reset test db'
	task :reset do
	    # Reset database
	    Rake::Task["db:reset"].invoke
	end

	task :test do
	    binding.pry
	    o=LegacyUser
	    LegacyUser.test
	    puts('done')
	    o.test
	end
    end

    namespace :dev do
	# Set the Rails environment
	Rails.env='development'
	# Info
	puts("Rails env=#{Rails.env}")

	desc 'import legacy data into DEV'
	task :import => :environment do
	end
    end


    desc 'import legacy data'
    task :import_data do
	# Turn off timestamp to import existing timestamps
	ActiveRecord::Base.record_timestamps = false

	# Variables
	user_map={}
	group_map={}

	# --------------- USER --------------
	LegacyUser.all.each do |u|
	    # Import user
	    old_id,new_id=u.migrate_me!
	    # Add to map
	    user_map[old_id]=new_id
	end
	# Test import
	LegacyUser.validate_import
	# --------------- GROUP --------------
	LegacyGroup.all.each do |o|
	    # Import data
	    old_id,new_id=o.migrate_me!
	    # Add to map
	    group_map[old_id]=new_id
	end
	# Test import
	LegacyGroup.validate_import
	# --------------- GROUP_MEMBER --------------
	# --------------- PAY_METHOD --------------
	# --------------- REASON --------------
	# --------------- STORE --------------
	# --------------- EXPENSE --------------
	# --------------- USER_CHARGE --------------
	# --------------- USER_PAYMENT --------------
	# --------------- BACKUP --------------
	# --------------- MORTGAGE_PAYMENT --------------


	# Turn timestamps back on
	ActiveRecord::Base.record_timestamps = true
    end

    # Method to count records
    def get_count(model)
	model.all.count
    end
end
