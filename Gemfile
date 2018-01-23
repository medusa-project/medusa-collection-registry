source 'https://rubygems.org'

gem 'sass'
gem 'rails', "~> 5.1"
gem 'responders'

#Rails (ActiveRecord) seems to want this version restriction on pg, though it doesn't seem to enforce it
# in a way that bundler understands.
# /active_record/connection_adapters/postgresql_adapter.rb has a 'gem' line with the restriction
gem 'pg', "~> 0.21"
gem 'postgresql_cursor'

#deployment webserver
gem 'passenger'
gem 'haml'
gem 'haml-rails'
#simple_form 3.3.1 was giving a problem with include_blank: false still including blanks, so we're pinning it back here
#cf https://github.com/plataformatec/simple_form/issues/1427
#cf https://github.com/plataformatec/simple_form/issues/1423
gem 'simple_form'
gem 'auto_html'
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
gem 'delayed_job_web'
gem 'daemons'
gem 'daemons-rails'

#image processing for file previews
#problem installing 1.0.5 - couldn't compile dependency glib2(3.0.8) on the servers
#revisit this later
#I think that this may have to wait until we get off RHEL 6 on these servers - even by
#hand I can't install the necessary libraries because of old dependencies.
#It also appears that ruby-vips -> 1.0.0 corresponds to vips7 -> vips8, which
#introduces some API changes and other complications - see the ruby-vips github page
#Alternately, we may just decide that Cantaloupe is good enough and get rid of the fallback, or revert
#the fallback to ImageMagick.
gem 'ruby-vips', '~>0.3.14', require: 'vips'

#AMQP communication - implicitly uses Bunny
# bunny is fixed because of problems deploying the 2.9 branch.
# We get OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
# Since there are no urgent security issues that I know about and since we may be replacing this soon anyway, I'm fine
# with pinning it
gem 'bunny'
gem 'amq-protocol'
gem 'amqp_helper', '~>0.1.4', git: 'git://github.com/medusa-project/amqp_helper.git'

gem 'sass-rails'
gem 'coffee-rails'

#make sure node.js is installed for asset compilation - no longer use therubyracer

gem 'uglifier'

gem 'bootstrap-sass'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'clipboard-rails'
gem 'underscore-rails'
gem 'underscore-string-rails'

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

# Medusa Book Tracker compatibility
gem 'local_time'

gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'draper'

gem 'uuid'
gem 'paperclip'

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
  gem 'sunspot_test'
  gem 'connection_pool'
  #need my version of bunny-mock where the default exchange works as expected. Wait to see if the fix gets merged
  gem 'bunny-mock', git: 'git://github.com/hading/bunny-mock.git'
  gem 'rack_session_access'
end
