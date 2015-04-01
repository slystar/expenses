require 'spec_helper'

describe "Returns" do

    before(:each) do
	@exp=get_valid_expense
	@attr={:description => Faker::Company.name, :expense_id => @exp.id, :transaction_date => Date.today, :user_id => @exp.user_id, :amount => @exp.amount - 1}
    end

    describe 'requires login for' do
	it "new" do
	    # Variables
	    path="#{returns_path}/new"
	    # Visit page
	    visit path
	    # Test
	    current_path.should == login_path
	end
	it "show" do
	    # Create return
	    return_obj=Return.create!(@attr)
	    # Variables
	    path="#{returns_path}/#{return_obj.id}"
	    # Visit page
	    visit path
	    # Test
	    current_path.should == login_path
	end

	it "index" do
	    # Create return
	    return_obj=Return.create!(@attr)
	    # Variables
	    path="#{returns_path}"
	    # Visit page
	    visit path
	    # Test
	    current_path.should == login_path
	end
    end
end
