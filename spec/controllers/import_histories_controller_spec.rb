require 'spec_helper'

describe ImportHistoriesController do

    before(:each) do
	@attr=get_attr_expense
	# Login a user
	@new_user_id=0
	user=get_next_user
	request.session[:user_id] = user.id
	@attr={:import_config_id => 1, :original_file_name => "uploaded_file.csv"}
	@attr_ic={:title => 'Amex', :description => 'CSV export of amex', :field_mapping => {:date_purchased => 0, :amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 1, :unique_id_hash_fields => [0,2,3], :date_type => 0}
    end

    def get_valid_import_history(attr=@attr)
	# Get a user
	u1=get_next_user
	# Get an import_config
	ic=get_valid_import_config(@attr_ic)
	# Set unique title
	ic.title=Faker::Name.name
	# Save ImportConfig
	ic.save!
	# Create ImportHistory
	ih=ImportHistory.new(attr)
	# Add user id because it should not be mass assignable
	ih.user_id=u1.id
	# Set the ImportConfig attribute
	ih.import_config_id=ic.id
	# Return object
	return ih
    end

    describe "GET 'show'" do
	it "returns http success" do
	    # Get ih
	    ih=get_valid_import_history
	    # Save
	    ih.save.should == true
	    get :show, :id => ih.id.to_s
	    response.should be_success
	end
    end

end
