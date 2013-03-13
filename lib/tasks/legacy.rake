namespace :legacy do
    # Required libraries
    require './lib/legacy_migration/legacy_base.rb'
    require './lib/legacy_migration/legacy_user.rb'
    require 'pry'

    desc 'migrate legacy data into DEV'
    task :import_dev => :environment do
	# Set the Rails environment
	Rails.env='development'
	# Info
	puts("Rails env=#{Rails.env}")
    end

    desc 'migrate legacy data into test'
    task :import_test => :environment do
	# Set the Rails environment
	Rails.env='test'
	# Info
	puts("Rails env=#{Rails.env}")

	# Reset database
	Rake::Task["db:reset"].invoke

	# Turn off timestamp to import existing timestamps
	ActiveRecord::Base.record_timestamps = false

	# Variables
	user_map={}
	# Migrate users
	LegacyUser.all.each do |u|
	    # Import user
	    old_id,new_id=u.migrate_me!
	    # Add to map
	    user_map[old_id]=new_id
	end
	# Test import
	LegacyUser.test_import
	p user_map

	# Turn timestamps back on
	ActiveRecord::Base.record_timestamps = true
    end

    # Method to count records
    def get_count(model)
	model.all.count
    end
end
