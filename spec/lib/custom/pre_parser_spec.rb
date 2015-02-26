require 'spec_helper'

describe PreParser do

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
	puts('aaa')
	p result=pp.parse(content,'test')
	# Test
	1.should == 2
    end
end
