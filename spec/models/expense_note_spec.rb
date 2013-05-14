require 'spec_helper'

describe ExpenseNote do

    before(:each) do
	@attr={:note => 'Test note for expense'}
    end

    it "should create a record with valid attributes" do
	ExpenseNote.create!(@attr)
    end

    it "should have a default app_version" do
	object=ExpenseNote.create!(@attr)
	object.app_version.should == 2
    end

    it "should be able to have a different app_version" do
	app_version=1
	object=ExpenseNote.new(@attr)
	object.app_version = app_version
	# Save
	object.save!
	object.reload
	# Test
	object.app_version.should == app_version
    end

    it "should have a note" do
	note=ExpenseNote.new(@attr.merge(:note => nil))
	# Test
	note.should_not be_valid
    end

    it "should respond to an expenses method" do
	# Create
	en=ExpenseNote.create!(@attr)
	# Test
	en.should respond_to(:expenses)
    end

    it "should start at version 0" do
	# Create
	en=ExpenseNote.new(@attr)
	# Test
	en.version.should == 0
	# Save
	en.save!
	# Test
	en.reload.version.should == 1
    end

    it "should increment version on updates to existing note" do
	# Create
	en=ExpenseNote.create!(@attr)
	# Check version
	en.version.should == 1
	# Update note
	en.note='2nd note'
	# Save
	en.save
	# Test
	en.version.should == 2
	# Update note
	en.note='3rd note'
	# Save
	en.save
	# Test
	en.version.should == 3
    end
end
