require 'spec_helper'

describe UserRole do

    before(:each) do
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testuserrole')
	@role=Role.create!(:name => Faker::Name.name, :description => 'Test user role')
	@attr={:user_id => @user.id, :role_id => @role.id}
    end

    pending "should create a new instance given valid attributes" do
    end
    pending "should not allow users to be in the same role more than once" do
    end
    
    pending "should allow users to be in multiple roles" do
    end

    pending "should map to a vlide user" do
    end

    pending "should map to a vlide role" do
    end

  pending "add some examples to (or delete) #{__FILE__}"
end
