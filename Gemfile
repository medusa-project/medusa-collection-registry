source 'https://rubygems.org'

gem 'rails', '~> 5.1'

gem 'alma_api', git: 'https://github.com/UIUCLibrary/alma-api-batch'

gem 'auto_html'
gem 'auto_strip_attributes'
gem 'config'
gem 'dalli'
gem 'haml'
gem 'haml-rails'
gem 'passenger'
gem 'pg'
gem 'postgresql_cursor'
gem 'responders'
gem 'rsync'
gem 'sass'
gem 'simple_form'
gem 'simple_memoize'
gem 'valid_email'

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
gem 'amq-protocol'
gem 'amqp_helper', '~>0.2.0', git: 'git://github.com/medusa-project/amqp_helper.git'
gem 'aws-sdk'
gem 'bootstrap-sass'
gem 'bunny'
gem 'cancancan'
gem 'coffee-rails'
gem 'daemons'
gem 'daemons-rails'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'httparty'
gem 'jbuilder'
gem 'marcel'
gem 'net-ldap'
gem 'nokogiri', '>= 1.10.4'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'rails-jquery-autocomplete'
gem 'react-rails', '~> 2.4.0'
gem 'sass-rails'
gem 'uglifier'
gem 'webpacker', '~> 4.x'

#memory/active record usage monitoring
gem 'draper'
gem 'oink'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem 'uuid'
#There are test failures going to 6.0, but I'm not sure why and it
# doesn't seem worth tracking them down when we may move to a different
# system for handling this.
gem 'csv_builder'
gem 'font-awesome-rails'
gem 'multi_json'
gem 'paperclip', '~> 5.2'
gem 'yajl-ruby'

#search
gem 'progress_bar'
gem 'sunspot_rails'

gem 'browser'
gem 'chartkick'
gem 'chronic'
gem 'hex_string'
gem 'lmdb'
gem 'medusa_storage', git: 'https://github.com/medusa-project/medusa_storage.git', branch: 'master'
gem 'os'
gem 'pdfjs_viewer-rails'
gem 'render_anywhere', require: false
gem 'send_file_with_range', git: 'https://github.com/tom-sherman/send_file_with_range.git', branch: 'master'

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'minitest-matchers_vaccine'
  gem 'puma'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 2.0'
  gem 'sunspot_solr'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.14.1'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'
  gem 'routler'
  gem 'traceroute'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-mechanize'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'json_spec'
  gem 'launchy'
  gem 'simplecov', require: false
  #testing with javascript - requires phantomjs to be installed on the test machine
  gem 'poltergeist'
  #simpler mocking than minitest
  gem 'mocha'

  #other js testing options
  #TODO pinned selenium-webdriver. If I go to 3.142.2 then performance suffers greatly when using chrome
  # headless. I do not know why at this time. Since this still works it seems worth waiting to see if
  # if gets chased down. Also the gem is about to go to 4.0, so maybe wait for that.
  gem 'connection_pool'
  gem 'selenium-webdriver', '3.142.1'
  gem 'sunspot_test'
  gem 'webdrivers'
  #need my version of bunny-mock where the default exchange works as expected. Wait to see if the fix gets merged
  gem 'bunny-mock', git: 'git://github.com/hading/bunny-mock.git'
  gem 'rack_session_access'
end
