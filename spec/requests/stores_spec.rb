require 'spec_helper'

describe "Stores:" do

    before(:each) do
	@stores=[]
	names=["Future Shop","Best Buy", "New Egg"]
	names.each{|name| @stores.push(Store.create(:name => name))}
    end

    describe "Controller methods:" do

	it "index" do
	    visit "#{stores_path}"
	    @stores.each do |store|
		page.should have_content(store.name)
	    end
	    page.should have_content("New Store")
	end

	it "show" do
	    store=@stores.first
	    visit "#{stores_path}/#{store.id}"
	    page.should have_content(store.name)
	    page.should have_content("Edit")
	    page.should have_content("Back")
	end

	it "new" do
	    stores_count=Store.find(:all).count
	    name="Test"
	    visit "#{stores_path}/new"
	    fill_in "Name", :with => name
	    click_on "Create Store"
	    page.should have_content(name)
	    page.should have_content("Edit")
	    page.should have_content("Back")
	    page.has_selector?("div#flash")
	    current_path.should == "#{stores_path}/#{stores_count + 1}"
	end

	it "edit"
	it "create"
	it "update"
	it "destroy"
    end

    describe "custom tests:" do
	it "gets the page successfully" do
	    get stores_path
	    response.status.should be(200)
	end

	it "should show an error when create a duplicate store" do
	    name=@stores.first.name
	    visit "#{stores_path}/new"
	    fill_in "Name", :with => name
	    click_on "Create Store"
	    page.has_selector?("div#error_explanation")
	    current_path.should == "#{stores_path}"
	end

	it "should show an error when renaming to a duplicate store"
    end
end
