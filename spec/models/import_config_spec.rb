require 'spec_helper'

describe ImportConfig do

    before(:each) do
	@attr={:user_id => 1, :title => 'Big bank import', :description => 'CSV export of Big Bank', :field_mapping => {:amount => 2, :store => 3}, :file_type => 'csv', :unique_id_field => 4, :unique_id_hash_fields => [2,3,4]}
    end

    it "should create a new instance given valid attributes" do
	ic=get_valid_import_config
	# Try to save
	ic.save!
    end

    it "should require a user_id" do
	ic=get_valid_import_config(@attr.merge(:user_id => nil ))
	ic.should_not be_valid
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
