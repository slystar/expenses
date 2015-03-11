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

    it "should check for valid pre_parsers" do
	# Test
	PreParser.should respond_to('valid_pre_parser?')
    end

    it "should return true on valid pre_parser" do
	# Test
	PreParser.valid_pre_parser?("test").should == true
    end

    it "should return false on missing pre_parser" do
	# Test
	PreParser.valid_pre_parser?("dummy").should == false
    end

    it "should have a test pre_parser" do
	# Test
	PreParser.valid_pre_parser?("test").should == true
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

    it "should parse CapitalOne CSV correctly" do
	# Test file
	filename='spec/imports/capital_one_mc.csv'
	# Get new object
	pp=PreParser.new
	# Get file content
	content=File.read(filename)
	# Parse file
	result=pp.parse(content,'p_mc_capital_one')
	# Parse CSV
	csv=CSV.parse(result)
	# Test row 1
	test_row(csv[0],["unique_id","date_purchased","store","amount","city","province"])
	# Test row 2
	test_row(csv[1],["9433a1c7c018e1bf88e5877ff31541d7ff3c9d0d","01/19/2015","aaaaaa bbbbbbbbb","85.00$","CITY2","ON"])
	# Test row 3
	test_row(csv[2],["2cd52cb6d135123803030585c5303acd6714580e","01/20/2015","PAIEMENT - MERCI","-103.00$",nil,nil])
	# Test row 4
	test_row(csv[3],["46219c401499ba778247924c486357d6c75e2c9f","01/22/2015","aaaaaa bbbbbb cccccc","123.00$","CITY1","ON"])
	# Test row 5
	test_row(csv[4],["8f2e5890decce7fafc97db34c944301eb579020c","01/22/2015","aaaaaaaaaaaaaaaaaaaa","21.11$","CITY1","ON"])
	# Test row 6
	test_row(csv[5],["a2e5c55a757a03898788399ca423c96f668acfbc","01/23/2015","aaaaaaaa bbbbbbbbb 111","38.18$","CITY3","ON"])
	# Size number of lines
	csv.size.should == 6
    end
end
