module SharedMethods
    def set_app_version
	# Set application version if none supplied
	self.app_version=2 if self.app_version.nil?
    end
end
