source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'pg'
gem 'active-fedora'
gem 'solrizer-fedora'

gem 'rb-readline'

#deployment webserver
gem 'passenger'

gem 'haml'
gem 'haml-rails'
gem 'simple_form'
gem 'auto_html'
gem 'simple_memoize'
gem 'auto_strip_attributes'

gem 'httpclient'
gem 'mechanize', :git => 'git://github.com/medusa-project/mechanize.git'
gem 'logger'
#need slightly patched version of this
gem 'net-http-digest_auth', :git => 'git://github.com/medusa-project/net-http-digest_auth.git'

gem 'acts_as_tree'
gem 'ruby-filemagic', :require => 'filemagic'

gem 'json_builder'

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

gem 'omniauth'
gem 'omniauth-shibboleth', :git => 'git://github.com/medusa-project/omniauth-shibboleth.git'
gem 'cancan', '~> 1.6.0'

gem 'handle-server', '~> 1.0.1', :git => 'git://github.com/medusa-project/handle-server.git'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

gem 'uuid'

group :development, :test do
  # To use debugger
  gem 'ruby-debug19'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'shoulda-matchers'
  gem 'thin'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'json_spec'
end