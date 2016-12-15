source 'https://rubygems.org'

gem 'sass'
gem 'rails', "~> 4.2"
gem 'responders'

gem 'pg'
gem 'postgresql_cursor'

#deployment webserver
gem 'passenger'
gem 'haml'
gem 'haml-rails'
#simple_form 3.3.1 was giving a problem with include_blank: false still including blanks, so we're pinning it back here
#cf https://github.com/plataformatec/simple_form/issues/1427
#cf https://github.com/plataformatec/simple_form/issues/1423
gem 'simple_form', '~> 3.2.1'
#auto_html 2.0 is breaking - need to fix up code before going, though right now I don't see that there is
#an improvment worth doing it for
gem 'auto_html', '~> 1.6.4'
gem 'ckeditor'
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
gem 'ruby-filemagic', '0.7.0', require: 'filemagic'

gem 'jbuilder'

gem 'delayed_job_active_record'
#Pin because later versions seem to have a problem with doing actions on the delayed jobs - they are aware of the problem
gem 'delayed_job_web', '1.2.5'
gem 'daemons'
gem 'daemons-rails'

#image processing for file previews
#problem installing 1.0.0 - couldn't compile dependency glib2(3.0.8) on the servers
#revisit this later
#I think that this may have to wait until we get off RHEL 6 on these servers - even by
#hand I can't install the necessary libraries because of old dependencies.
#It also appears that ruby-vips -> 1.0.0 corresponds to vips7 -> vips8, which
#introduces some API changes and other complications - see the ruby-vips github page
#Alternately, we may just decide that Cantaloupe is good enough and get rid of the fallback, or revert
#the fallback to ImageMagick.
gem 'ruby-vips', '~>0.3.14', require: 'vips'

#AMQP communication - implicitly uses Bunny
gem 'amqp_helper', '~>0.1.4', git: 'git://github.com/medusa-project/amqp_helper.git'

gem 'sass-rails'
gem 'coffee-rails'
gem 'html5shiv-js-rails'

#make sure node.js is installed for asset compilation - no longer use therubyracer

gem 'uglifier'

gem 'bootstrap-sass'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'clipboard-rails'
gem 'underscore-rails'
gem 'underscore-string-rails'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'cancan'
gem 'handle-server', '~> 1.0.1', git: 'git://github.com/medusa-project/handle-server.git'
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
gem 'paperclip'#, git: 'git://github.com/thoughtbot/paperclip.git'

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

gem 'chartkick'

#date parsing
gem 'chronic'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'shoulda-matchers'
  gem 'sunspot_solr'
  gem 'byebug'
  gem 'puma'
end

group :development do
  #gem 'newrelic_rpm'
  gem 'traceroute'
  #gem 'rack-mini-profiler'
  #gem 'bullet'
  #gem 'brakeman', require: false
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
  #We can start using this again when it support capybara 2.8
  #gem 'capybara-webkit'
  gem 'sunspot_test'
  gem 'connection_pool'
  #need my version of bunny-mock where the default exchange works as expected. Wait to see if the fix gets merged
  gem 'bunny-mock', git: 'git://github.com/hading/bunny-mock.git'
end
