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

    pending "should require a description" do
    end

    pending "should have a unique name" do
    end
    
    pending "should be destroyable if no users are assigned to it" do
    end

    pending "should not be destroyable if users are assigned to it" do
    end
  pending "add some examples to (or delete) #{__FILE__}"
end
