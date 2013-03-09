require 'spec_helper'

describe "Stores:" do

    before(:each) do
	@stores=[]
	names=["Future Shop","Best Buy", "New Egg"]
	names.each{|name| @stores.push(Store.create!(:name => name))}
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

	it "edit" do
	    id=1
	    name="Canadian Tire"
	    visit "#{stores_path}/#{id}/edit"
	    fill_in "Name", :with => name
	    click_on "Update Store"
	    page.should have_content(name)
	    page.should have_selector('a', :visible => "#{stores_path}/#{id}/edit")
	    page.should have_selector('a', :visible => "#{stores_path}")
	    page.should have_selector("div#flash_notice")
	    current_path.should == "#{stores_path}/#{id}"
	end

	it "create" do
	    stores_count=Store.find(:all).count
	    name="Test"
	    visit "#{stores_path}/new"
	    fill_in "Name", :with => name
	    click_on "Create Store"
	    page.should have_content(name)
	    page.should have_content("Edit")
	    page.should have_content("Back")
	    page.should have_selector("div#flash_notice")
	    current_path.should == "#{stores_path}/#{stores_count + 1}"
	    #page.driver.browser.switch_to.alert.accept
	end

	it "destroy" do
	    id=2
	    visit stores_path
	    start_count=all('a').select { |a| a[:href] =~ /#{stores_path}\/[0-9]\/edit/ }.count
	    rack_test_session_wrapper = Capybara.current_session.driver
	    rack_test_session_wrapper.delete "#{stores_path}/#{id}"
	    visit stores_path
	    end_count=all('a').select { |a| a[:href] =~ /#{stores_path}\/[0-9]\/edit/ }.count
	    end_count.should == (start_count - 1)
	    link=all('a').select{|a| a[:href] == "#{stores_path}/#{id}/edit"}.first
	    link.should be_nil
	end
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
	    page.should have_selector("div#error_explanation")
	    current_path.should == "#{stores_path}"
	end

	it "should show an error when renaming to a duplicate store" do
	    id=1
	    existing_name=Store.find(id).name
	    name=@stores[1].name
	    name.should_not == existing_name
	    visit "#{stores_path}/#{id}/edit"
	    fill_in "Name", :with => name
	    click_on "Update Store"
	    page.should have_selector('a', :visible => "#{stores_path}")
	    page.should have_selector("div#error_explanation")
	    current_path.should == "#{stores_path}/#{id}"
	end
    end
end
