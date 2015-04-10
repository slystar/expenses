require 'spec_helper'

describe "Returns" do

    before(:each) do
	@exp=get_valid_expense
	@attr={:description => Faker::Company.name, :expense_id => @exp.id, :transaction_date => Date.today, :user_id => @exp.user_id, :amount => @exp.amount - 1}
    end

    def get_errors(p)
	# Set flag
	flag=false
	# Loop over body
	p.body.each_line do |line|
	    # Set flag to not print line
	    flag=false if line =~ /<\/div>/
	    # Print line if flag is set
	    puts line.gsub(/<[^>]*>/,'') if flag
	    # Set flag to start printing lines
	    flag=true if line =~ /error_explanation/
	end
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

    describe 'after login' do

	before(:each) do
	    # Get user
	    @user=get_next_user
	    # Create user
	    @user.save!
	    # Login
	    login_user(@user)
	end

	def login_user(user)
	    # Visit login page
	    visit login_path
	    # Fill in info
	    page.fill_in "user_name", with: user.user_name
	    page.fill_in "password", with: user.password
	    # Click button to submit
	    page.click_button "Log in"
	end

	describe 'new' do
	    before(:each) do
		# Save expense
		@exp.save.should == true
		# Variables
		@add_path="#{returns_path}/new"
		# Get a valid return
		@object=Return.new
		# Visit page
		visit @add_path
	    end

	    it "should create a return given valid attributes" do
		# Fill information
		page.fill_in "return_expense_id", with: @exp.id
		page.fill_in "return_amount", with: @exp.amount / 2.00
		page.fill_in "return_description", with: 'test description'
		# Test: Record created
		lambda{
		    page.click_button 'Create Return'
		}.should change(Return,:count).by(1)
		# Test
		current_path.should == @add_path
		page.should have_content('Return was successfully created.')
	    end

	    it "should display an error message when trying to save an invalid record" do
		# Fill some information
		page.fill_in "return_expense_id", with: @exp.id
		page.fill_in "return_description", with: 'test description'
		# Test: Record created
		lambda{
		    page.click_button 'Create Return'
		}.should change(Return,:count).by(0)
		# Test
		current_path.should == returns_path
		page.should have_content('errors prohibited this return from being saved')
	    end
	end
    end
end
