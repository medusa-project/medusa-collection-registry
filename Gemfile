source 'https://rubygems.org'

gem 'rails', "~> 4.0.1.rc1"
gem 'activerecord-session_store'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'pg'
gem 'active-fedora'

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

gem 'jbuilder'

#custom gem that uses a web service to generate fits.
gem 'fits', '~> 1.0.6', :git => 'git://github.com/medusa-project/fits.git'

gem 'delayed_job_active_record'
gem 'daemons'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'less-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.4'

  gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
#use fork for rails 4 support
gem 'rails3-jquery-autocomplete', git: 'https://github.com/francisd/rails3-jquery-autocomplete'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth', :git => 'git://github.com/medusa-project/omniauth-shibboleth.git'
gem 'cancan', '~> 1.6.0'

gem 'handle-server', '~> 1.0.1', :git => 'git://github.com/medusa-project/handle-server.git'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

gem 'uuid'
gem 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'

group :development, :test do
  # To use debugger
  #gem 'ruby-debug19'
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
  gem 'capybara'
  gem 'capybara-email'
  gem 'launchy'
end