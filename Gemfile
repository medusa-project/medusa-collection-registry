source 'https://rubygems.org'

gem 'sass'
gem 'rails', "~> 4.2"
gem 'responders'

gem 'pg'

#deployment webserver
gem 'passenger'
gem 'haml'
gem 'haml-rails'
gem 'simple_form'
gem 'auto_html'
gem 'ckeditor'
gem 'simple_memoize'
gem 'auto_strip_attributes'
gem 'dalli'
gem 'valid_email'
gem 'rsync'

gem 'logger'
#need slightly patched version of this
gem 'net-http-digest_auth', git: 'git://github.com/medusa-project/net-http-digest_auth.git'

gem 'ruby-filemagic', require: 'filemagic'

gem 'jbuilder'

#custom gem that uses a web service to generate fits.
gem 'fits', '~> 1.0.6', git: 'git://github.com/medusa-project/fits.git'

gem 'delayed_job_active_record'
#Pin because later versions seem to have a problem with doing actions on the delayed jobs - they are aware of the problem
gem 'delayed_job_web', '1.2.5'
gem 'daemons'
gem 'daemons-rails'

#image processing for file previews
gem 'ruby-vips', require: 'vips'

#AMQP communication
gem 'bunny'

gem 'sass-rails'
gem 'coffee-rails'
gem 'less-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'

gem 'uglifier'

# The "bootstrap3" branch is no longer needed -- bootstrap 3.2 is the default
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails'
gem 'rails-jquery-autocomplete'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'cancan'
gem 'handle-server', '~> 1.0.1', git: 'git://github.com/medusa-project/handle-server.git'
gem 'rest-client'
gem 'httparty'
gem 'net-ldap'

# Deploy with Capistrano
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-rvm'
gem 'capistrano-passenger'

#memory/active record usage monitoring
gem 'oink'

# Medusa Book Tracker compatibility
gem 'local_time'

gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'draper'

gem 'uuid'
gem 'paperclip', git: 'git://github.com/thoughtbot/paperclip.git'

gem 'font-awesome-rails'

#search
gem 'sunspot_rails'
gem 'progress_bar'

gem 'render_anywhere', require: false

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'shoulda-matchers'
  gem 'thin'
  #The default 2.2.0 sunspot_solr will work for dev/testing. If you
  #want something newer (2.2.0 still uses solr 4; master has solr 5, and
  #you might want it to consult the schema.xml, etc.) then clone the
  #sunspot repo and build and install sunspot_solr manually (it is
  #in a subdir, and I don't know a way to automatically get and use it)
  gem 'sunspot_solr'
end

group :development do
  gem 'newrelic_rpm'
end

group :test do
  #gem 'cucumber', '~> 2.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'json_spec'
  gem 'capybara'
  gem 'capybara-email'
  gem 'launchy'
  #testing with javascript - requires phantomjs to be installed on the test machine
  gem 'poltergeist'
  #other js testing options
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'sunspot_test'
  gem 'connection_pool'
end
