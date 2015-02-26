class PreParser
    # Method to parse data
    def parse(file_content,pre_parser_name)
	# Check if pre_parser exists
	if not self.respond_to?(pre_parser_name.to_sym)
	    return nil
	end
	# Prepare data
	@file_content=file_content
	# Call proper pre_parser
	self.__send__(pre_parser_name)
    end

    # Test pre_parser
    def test
	# Loop over content
	file_content.each_line do |line|
	    p line
	end
    end
end
