require 'spec_helper'

describe UserRole do

    before(:each) do
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testuserrole')
	@role=Role.create!(:name => Faker::Name.name, :description => 'Test user role')
	@attr={:user_id => @user.id, :role_id => @role.id}
    end

    it "should create a new instance given valid attributes" do
	UserRole.create!(@attr)
    end

    it "should have a default app_version" do
	object=UserRole.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=UserRole.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should not allow users to be in the same role more than once" do
	# Create user_role
	ur=UserRole.create!(@attr)
	# Create duplicate user_role
	ur2=UserRole.new(@attr)
	# Check validity
	ur2.should_not be_valid
    end
    
    it "should allow users to be in multiple roles" do
	# Create user_role
	ur=UserRole.create!(@attr)
	# Create 2nd role
	role2=Role.create!(:name => Faker::Name.name, :description => 'Test user role tmp')
	# Create 2nd user_role with new role
	ur2=UserRole.new(@attr.merge(:role_id => role2.id))
	# Valid?
	ur2.should be_valid
    end

    it "should map to a valid user" do
	# Create user_role with non existing user
	ur=UserRole.new(@attr.merge(:user_id => 99999))
	# Valid?
	ur.should_not be_valid
    end

    it "should map to a valid role" do
	# Create user_role with non existing user
	ur=UserRole.new(@attr.merge(:role_id => 99999))
	# Valid?
	ur.should_not be_valid
    end

    it "should be destroyable even if the user still exists" do
	# Create user role
	ur=UserRole.create!(@attr)
	# Get user
	user=ur.user	
	# Destroy user role
	ur.destroy
	# Valid?
	ur.should be_destroyed
    end
end
