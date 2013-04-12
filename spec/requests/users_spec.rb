require 'spec_helper'

describe "Users" do
    describe 'Sign up' do
	before { visit signup_path }

	it { page.should have_selector('h1', text: 'Sign up') }

	it "should have the proper tile" do
	     first('head title').native.text.should == 'Expenses'
	end

	it "should have proper input fields" do
	    # Variables
	    expected_input_types={"hidden"=>1, "text"=>2, "password"=>2, "submit"=>1}
	    found_input_types={}
	    # Input: text
	    page.should have_field('user_user_name')
	    page.should have_field('name')
	    page.all('input[type=text]').size.should == 2
	    # Input: password
	    page.should have_field('user_password')
	    page.should have_field('user_password_confirmation')
	    page.all('input[type=password]').size.should == 2
	    # check all input fields
	    page.all('input').each do |e|
		# Get nokogiri object
		nok=e.native
		# Get attributes
		attributes=nok.attributes
		# Loop over attributes
		attributes.each do |x|
		    # Get type
		    type=x[0]
		    value=x[1].value
		    # Process only 'type'
		    next if type != 'type'
		    # Create hash if it does not exist
		    found_input_types[value]=0 if found_input_types[value].nil?
		    # Add to count
		    found_input_types[value] += 1
		end
	    end
	    expected_input_types.should == found_input_types
	end
    end

    describe "GET /users" do
	it "works! (now write some real specs)" do
	    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
	    get users_path
	    response.status.should be(200)
	end
    end
end
