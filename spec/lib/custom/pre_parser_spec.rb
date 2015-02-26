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

    it "should return nil when a pre_parser does not exist" do
	# Get new object
	pp=PreParser.new
	# Test
	pp.parse('dummy file content','aaa').should be_nil
    end

    pending "should parse the test file correctly" do
    end
end
