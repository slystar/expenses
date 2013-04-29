require 'spec_helper'

describe "Expenses" do
    it "should have a menu page with required links" do
	# Visit page
	visit(menu_path)
	# Test
	page.should have_link("Add expense")
	page.should have_link("Edit user")
	page.should have_link("Logout")
    end

    describe "Add" do
	before(:each) do
	    visit "#{expenses_path}/new"
	end
	it "should be able to add a valid record" do
	    1.should == 5
	end
    end

    describe "GET /expenses" do
	it "works! (now write some real specs)" do
	    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
	    get expenses_path
	    response.status.should be(200)
	end
    end
end
