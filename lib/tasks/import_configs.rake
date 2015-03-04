namespace :import_configs do

    # Set the Rails environment
    #Rails.env='development'
    # Info
    puts("Rails env=#{Rails.env}")

    desc 'Add known import_configs'
    task :add_defaults => :environment do
	# Amex attributes
	attr_ic_amex={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
	# Create amex ImportConfig
	find_or_create(attr_ic_amex,'American Express')

	# PC attributes
	attr_ic_pc={:title => 'PC', :description => 'CSV export of PC MC', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 7, :unique_id_hash_fields => [0,2,3], :date_type => 0}
	# Create PC ImportConfig
	find_or_create(attr_ic_pc,'Master Card')

	# Capital One Master Card
	attr_ic_capital_one_mc={:title => 'CapitalOne MC', :description => 'CSV export of CapitalOne MC', :field_mapping => {:date_purchased => 1, :amount => 3, :store => 2}, :file_type => 'csv', :unique_id_field => 0, :unique_id_hash_fields => [1,2,3], :date_type => 0, :pre_parser => 'p_mc_capital_one'}
	# Create PC ImportConfig
	find_or_create(attr_ic_capital_one_mc,'Master Card')
    end

    # Function to create ImportConfig
    def find_or_create(ic_attr, pay_method_name)
	# Get title
	title=ic_attr[:title]
	# Look for existing
	lookup=ImportConfig.where(:title => title)
	# Check
	if lookup.empty?
	    # Info
	    puts("Creating: #{title}")
	    # Create
	    ic=ImportConfig.new(ic_attr)
	    # Get first user
	    user=User.first
	    # Set user
	    ic.user_id=user.id
	    # Get pay method
	    pay_method=PayMethod.where(:name => pay_method_name).first
	    # Check pay_method
	    if pay_method.nil?
		puts("Error: pay_method not found: #{pay_method_name}")
		return nil
	    end
	    # Set pay_method_id
	    ic.pay_method_id=pay_method.id
	    # Save
	    ic.save!
	else
	    # Info
	    puts("Found: #{title}")
	    return lookup
	end
    end
end
