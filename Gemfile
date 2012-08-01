source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'pg'
gem 'active-fedora'
gem 'solrizer-fedora'

#deployment webserver
gem 'passenger'

gem 'haml'
gem 'simple_form'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
  
  gem 'twitter-bootstrap-rails'
  
end

gem 'jquery-rails'

gem 'nokogiri'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

group :development, :test do
  # To use debugger
  gem 'ruby-debug19'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'shoulda-matchers'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'simplecov'
end