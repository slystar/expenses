class Backup < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :backup_date, :backup_dir_size_KB

    # Validations
    validates :backup_date, :presence => true
    validates :backup_dir_size_KB, :presence => true, :numericality => true

    # Method to backup database
    def dump(env)
	# Use yaml_db to dump data to file
	result=`rake db:dump RAILS_ENV=#{env}`
    end
end
