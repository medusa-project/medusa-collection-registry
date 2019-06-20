source 'https://rubygems.org'

gem 'sass'
gem 'rails', "~> 5.1"
gem 'responders'

gem 'pg'
gem 'postgresql_cursor'

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
gem 'config'

gem 'logger'
#need slightly patched version of this
gem 'net-http-digest_auth', git: 'git://github.com/medusa-project/net-http-digest_auth.git'

#pinned for a problem compiling 0.7.1 on our servers
# I think I have the problem fixed, but if it won't compile then repin this
#gem 'ruby-filemagic', '0.7.0', require: 'filemagic'
gem 'ruby-filemagic'
#This is a potential replacement to ruby-filemagic that is pure ruby and capable of working on IOs,
# hence might work with S3 better. I'm adding it in order to have it available to do some testing.
# It actually might be used by rails itself, but I want to be explicit about it if we're using
# it directly.
gem 'marcel'

gem 'jbuilder'

gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'
gem 'daemons-rails'

gem 'bunny'
gem 'amq-protocol'
gem 'amqp_helper', '~>0.2.0', git: 'git://github.com/medusa-project/amqp_helper.git'

gem 'sass-rails'
gem 'coffee-rails'

#make sure node.js is installed for asset compilation - no longer use therubyracer

gem 'uglifier'

gem 'bootstrap-sass'

#TODO update to webpacker 4. This is at least a bit involved. There is info here:
# https://github.com/rails/webpacker and more specifically here
# https://github.com/rails/webpacker/blob/master/docs/v4-upgrade.md
# Suffice to say that I naively tried all of that and it did not immediately work, so there
# is likely at least a bit of thinking to do.
gem 'webpacker', '~> 3.5.5'

gem 'rails-jquery-autocomplete'

gem 'react-rails', '~> 2.4.0'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'cancancan'
gem 'handle-server', '~> 1.0.1', git: 'git://github.com/medusa-project/handle-server.git'
gem 'httparty'
gem 'net-ldap'

# Deploy with Capistrano
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-rbenv'
gem 'capistrano-passenger'
gem 'capistrano-yarn'

#memory/active record usage monitoring
gem 'oink'

gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'draper'

gem 'uuid'
#There are test failures going to 6.0, but I'm not sure why and it
# doesn't seem worth tracking them down when we may move to a different
# system for handling this.
gem 'paperclip', '~> 5.2'

gem 'font-awesome-rails'

gem 'multi_json'
gem 'yajl-ruby'
gem 'csv_builder'

#search
gem 'sunspot_rails'
gem 'progress_bar'

gem 'render_anywhere', require: false

gem 'os'
gem 'lmdb'

## For this group we are installing the js via webpack/yarn,
## but it is still useful to get the view helpers
gem 'chartkick'
# Medusa Book Tracker compatibility
gem 'local_time'


#date parsing
gem 'chronic'

gem 'send_file_with_range', git: 'https://github.com/tom-sherman/send_file_with_range.git', branch: 'master'
gem 'pdfjs_viewer-rails'

gem 'medusa_storage', git: 'https://github.com/medusa-project/medusa_storage.git', branch: 'master'

gem 'hex_string'

gem 'browser'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'sunspot_solr'
  gem 'byebug'
  gem 'puma'
end

group :development do
  #gem 'newrelic_rpm'
  gem 'traceroute'
  gem 'routler'
  #gem 'rack-mini-profiler'
  #gem 'bullet'
  #gem 'brakeman', require: false
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'json_spec'
  #Lock this on 2.x, as going to 3 will probably require some fixing up
  gem 'capybara'#, '~> 2.18'
  gem 'capybara-email'
  gem 'capybara-mechanize'
  gem 'launchy'
  #testing with javascript - requires phantomjs to be installed on the test machine
  gem 'poltergeist'
  #simpler mocking than minitest
  gem 'mocha'

  #other js testing options
  #TODO pinned selenium-webdriver. If I go to 3.142.2 then performance suffers greatly when using chrome
  # headless. I do not know why at this time. Since this still works it seems worth waiting to see if
  # if gets chased down. Also the gem is about to go to 4.0, so maybe wait for that.
  gem 'selenium-webdriver', '3.142.1'
  gem 'webdrivers'

  gem 'sunspot_test'
  gem 'connection_pool'
  #need my version of bunny-mock where the default exchange works as expected. Wait to see if the fix gets merged
  gem 'bunny-mock', git: 'git://github.com/hading/bunny-mock.git'
  gem 'rack_session_access'
end
