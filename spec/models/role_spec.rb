require 'spec_helper'

describe Role do

    before(:each) do
	@attr={:name => "admin_role", :description => "Test Admin role"}
    end

    it "should create a new instance given valid attributes" do
	# Create role
	Role.create!(@attr)
    end

    it "should require a name" do
	# Create role
	r=Role.new(@attr.merge(:name => nil))
	# Should not be valid
	r.should_not be_valid	
    end

    it "should require a uniq name" do
	# Create role
	r1=Role.create!(@attr)
	# Get name
	name=r1.name
	# Create a second role
	r2=Role.new(@attr)
	# Should not be valid
	r2.should_not be_valid	
    end

    it "should require a uniq name, case insensitive" do
	# Create role
	r1=Role.create!(@attr)
	# Get name
	name=r1.name
	# Create a second role
	r2=Role.new(@attr.merge(:name => name.upcase))
	# Make sure they are not the same
	r1.name.should_not == r2.name
	# Should not be valid
	r2.should_not be_valid	
    end

    it "should require a description" do
	# Create role
	r=Role.new(@attr.merge(:description => nil))
	# Should not be valid
	r.should_not be_valid	
    end
    
    it "should be destroyable if no users are assigned to it" do
	# Create role
	r=Role.create!(@attr)
	# Destroy role
	r.destroy
	# Should  be destroyed
	r.should be_destroyed
    end

    it "should not be destroyable if users are assigned to it" do
	# Create role
	r=Role.create!(@attr)
	# Create user
	u=User.create!(:user_name => Faker::Name.name, :password => 'testrole123')
	# Add user to role
	ur=UserRole.create!(:user_id => u.id, :role_id => r.id)
	# Destroy role
	r.destroy
	# Should not be destroyed
	r.should_not be_destroyed
    end
end
