require 'spec_helper'

describe GroupMember do
    def create_group
	group=Group.create!(:name => Faker::Company.name)
    end

    before(:each) do
	@user=User.create!(:user_name => Faker::Name.name, :password => 'testgroupmember')
	@group=create_group
	@attr={:user_id => @user.id, :group_id => @group.id}
    end

    it "should create a new instance given valid attributes" do
	GroupMember.create!(@attr)
    end

    it "should require a user_id" do
	gm=GroupMember.new(@attr.merge(:user_id => nil))
	gm.should_not be_valid
    end

    it "should require a group_id" do
	gm=GroupMember.new(@attr.merge(:group_id => nil))
	gm.should_not be_valid
    end

    it "should not allow a user to be in the same group more than once" do
	gm=GroupMember.create!(@attr)
	gm2=GroupMember.new(@attr)
	gm2.should_not be_valid
    end

    it "should allow a user to be in different groups" do
	group2=create_group
	gm=GroupMember.create!(@attr)
	gm2=GroupMember.new(@attr.merge(:group_id => group2.id))
	gm2.should be_valid
    end

    it "should map to a valid user" do
	gm=GroupMember.new(@attr.merge(:user_id => 99999))
	gm.should_not be_valid
    end

    it "should map to a vlid group" do
	gm=GroupMember.new(@attr.merge(:group_id => 99999))
	gm.should_not be_valid
    end
end
