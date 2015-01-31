source 'http://rubygems.org'

gem 'rails', '~> 3.2.12'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
    gem 'sass-rails',   '~> 3.2.3'
    gem 'coffee-rails', '~> 3.2.1'
    gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'
# Haml
gem 'haml-rails'
# For database backups
gem 'yaml_db'

# Use unicorn as the web server
# gem 'unicorn'
# Use puma as the web server
gem 'puma'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem 'rspec-rails', '>= 2.6.1'
  gem 'spork', '~> 0.9.0.rc'
  gem 'capybara'
  gem 'watchr'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'guard-spork'
  # To import from old database
  gem 'mysql2'
  gem 'activerecord-mysql-adapter'
  # To better troubleshoot
  #gem 'pry'
  #gem 'pry-debugger'
end

group :development do
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'rb-inotify'
  gem 'libnotify'
  gem 'rails-erd'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'activesupport'
  #gem 'webrat', '>= 0.7.1'
  gem 'faker'
end
