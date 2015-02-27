require 'spec_helper'

describe PreParser do

    # Method to compare a row with target information
    def test_row(row,target)
	# Loop over row
	row.each_index do |i|
	    # Compare row with target information
	    row[i].should == target[i]
	end
    end

    it "should have a parse method" do
	# Get new object
	pp=PreParser.new
	# Test
	pp.should respond_to('parse')
    end

    it "should have a test method" do
	# Get new object
	pp=PreParser.new
	# Test
	pp.should respond_to('test')
    end

    it "should raise an error when a pre_parser does not exist" do
	# Get new object
	pp=PreParser.new
	# Test
	lambda{pp.parse('dummy file content','aaa')}.should raise_error
    end

    it "should parse the test file correctly" do
	# Test file
	filename='spec/imports/pre_parser_test.csv'
	# Get new object
	pp=PreParser.new
	# Get file content
	content=File.read(filename)
	# Parse file
	result=pp.parse(content,'test')
	# Parse CSV
	csv=CSV.parse(result)
	# Test row 1
	test_row(csv[0],["unique_id","date_purchased","store","amount","city","province"])
	# Test row 2
	test_row(csv[1],["a043af2755df9d42e8e576136c35f44042fa808f","01/19/2015","Store Title1","85.00$","CITY1","ON"])
	# Test row 3
	test_row(csv[2],["233814021740e4fac22d6ea1d5b2b9d6fffb4db8","01/20/2015","PAIEMENT - MERCI","-103.00$",nil,nil])
	# Test row 4
	test_row(csv[3],["346d3757992fd59bb40900254eb123d51f9f72b9","01/22/2015","Store Title2 Co","123.00$","CITY2","ON"])
	# Size number of lines
	csv.size.should == 4
    end
end
