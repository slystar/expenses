require 'spec_helper'

describe User do

    pending "add some examples to (or delete) #{__FILE__}"

    before(:each) do
	@attr={:user_name => 'test', :password => 'test'}
    end

    it "should be unique" do
	User.create!(@attr)
	user=User.new(@attr)
	user.should_not be_valid
    end

end
