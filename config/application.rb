require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Expenses
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib/validators #{config.root}/lib/custom)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :check_for_expenses_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.template_engine :haml
      # see http://everydayrails.com/2012/03/12/testing-series-rspec-setup.html
      g.test_framework :rspec,
	  :fixtures => true,
	  :view_specs => false,
	  :helper_specs => true,
	  :routing_specs => false,
	  :controller_specs => true,
	  :request_specs => true
      g.fixtrue_replacement :factory_girl, :dir => "spec/factories"
    end

    # Custom application variables
    Rails.configuration.upload_path = "uploads"

    # Current tag file
    tag_file=File.join('public','tag.txt')
    # Check if file exists
    if File.exist?(tag_file)
	# Get git tag
	git_tag=File.read(tag_file).chomp
	# Set variable
	Rails.configuration.git_tag=git_tag
    else
	Rails.configuration.git_tag="No tag file: #{tag_file}"
    end
  end
end
