source 'https://rubygems.org'

gem 'rails', "~> 4.1"

gem 'pg'

#deployment webserver
gem 'passenger'
gem 'haml'
gem 'haml-rails'
gem 'simple_form'
gem 'auto_html'
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

#fixes a problem caused by our old postgres version
#gem 'delayed_job_active_record', git: 'git://github.com/medusa-project/delayed_job_active_record.git'
gem 'delayed_job_active_record', git: 'git://github.com/panter/delayed_job_active_record.git'
gem 'daemons'

#image processing for file previews
gem 'mini_magick'

#creation of bags for off-site archiving of files
gem 'bagit'
gem 'tree.rb', require: 'tree_rb'

#AMQP communication
gem 'bunny'

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'less-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier'

  # The "bootstrap3" branch is no longer needed -- bootstrap 3.2 is the default
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

#end

gem 'jquery-rails'
gem 'jquery-ui-rails'
#TODO note that as of 1.0.14 at least this hits a deprecation of simple_form, using 'def input' instead of
#'def input(wrapper_options)'.
gem 'rails3-jquery-autocomplete'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth', git: 'git://github.com/medusa-project/omniauth-shibboleth.git'
gem 'cancan'
gem 'handle-server', '~> 1.0.1', git: 'git://github.com/medusa-project/handle-server.git'
gem 'rest-client'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# Medusa Book Tracker compatibility
gem 'local_time'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem 'uuid'
gem 'paperclip', git: 'git://github.com/thoughtbot/paperclip.git'

gem 'font-awesome-rails'
gem 'state_machine'

group :development, :test do
  # To use debugger
  #gem 'ruby-debug19'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'shoulda-matchers'
  gem 'thin'
  gem 'newrelic_rpm'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'json_spec'
  gem 'capybara'
  gem 'capybara-email'
  gem 'launchy'
end
