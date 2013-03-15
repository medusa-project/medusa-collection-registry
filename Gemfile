source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'pg'
gem 'active-fedora'
gem 'solrizer-fedora'

gem 'rb-readline'

#deployment webserver
#TODO - Was having problems with deploying with 3.0.19, so look into that sometime. For now pin. The problem was
#somewhere in passenger compiling/deploying itself on the production server.
gem 'passenger', '3.0.15'

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

#custom gem that uses a web service to generate fits. The ethon dependency will be
#removable after ethon 0.5.11 is released
gem 'fits', '~> 1.0.6', :git => 'git://github.com/medusa-project/fits.git'
puts "Using master version of ethon - remove after new release of ethon"
gem 'ethon', :git => "git://github.com/typhoeus/ethon.git", :branch => 'master'

gem 'delayed_job_active_record'
gem 'daemons'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'less-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.4'

  gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails'

gem 'nokogiri'

gem 'omniauth'
gem 'omniauth-shibboleth', :git => 'git://github.com/medusa-project/omniauth-shibboleth.git'
gem 'cancan', '~> 1.6.0'

gem 'handle-server', '~> 1.0.1', :git => 'git://github.com/medusa-project/handle-server.git'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

gem 'uuid'

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
  #see note in cucumber env - when 2.0.3 or 2.1 becomes available, with Capybara.match configuration then we can unpin and fix cucumber env
  gem 'capybara', "~> 1.1.4"
end