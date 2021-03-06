# Require helper
require './lib/legacy_migration/helper.rb'
# Include helper
include LegacyHelper

class LegacyBase < ActiveRecord::Base
    establish_connection(
	:adapter => "mysql2",
	:host => "localhost",
	:username => "rails_test",
	:password => "rails_test$",
	:database => "rails_test"
    )
    self.abstract_class = true
end
