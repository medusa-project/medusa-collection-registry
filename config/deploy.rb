require 'bundler/capistrano'
require 'rvm/capistrano'
require 'auto_html/capistrano'

set :production_server, "medusa.library.illinois.edu"
set :staging_server, "medusatest.library.illinois.edu"
default_run_options[:shell] = '/bin/bash -l'

task :production do
  role :web, production_server
  role :app, production_server
  role :db, production_server, primary: true
end

task :staging do
  role :web, staging_server
  role :app, staging_server
  role :db, staging_server, primary: true
end

set :application, "Medusa"
set :repository, "git://github.com/medusa-project/medusa-rails3.git"

set :scm, :git
set :deploy_via, :remote_cache

set :user, 'medusa'
set :use_sudo, false

set :home, "/services/medusa"
set :deploy_to, "#{home}/medusa-rails3-capistrano"
set :shared, "#{deploy_to}/shared"
set :shared_config, "#{shared}/config"
set :public, "#{current_path}/public"

set :local_root, File.expand_path('..', File.dirname(__FILE__))

namespace :deploy do
  desc "link shared configuration"
  task :link_config do
    ['database.yml', 'fedora.yml', 'solr.yml', 'shibboleth.yml', 'handle_client.yml',
     'dx.yml', 'fits_service.yml', 'medusa.yml', 'smtp.yml'].each do |file|
      run "ln -nfs #{shared_config}/#{file} #{current_path}/config/#{file}"
    end
  end

  desc "Start rails"
  task :start do
    run "cd #{home}/bin ; ./start-rails"
  end
  desc "Stop rails"
  task :stop do
    run "cd #{home}/bin ; ./stop-rails || echo 'Passenger not currently running'"
  end
  desc "Restart rails"
  task :restart, roles: :app, except: {no_release: true} do
    ;
  end

  desc "seed database"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc "precompile rails assets"
  task :precompile_assets do
    run "cd #{current_path}; bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end
end

namespace :medusa do

  desc "start delayed_job"
  task :start_delayed_job do
    run "cd #{current_path}; bundle exec rake medusa:delayed_job:start RAILS_ENV=#{rails_env}"
  end

  desc "stop delayed_job"
  task :stop_delayed_job do
    run "cd #{current_path}; bundle exec rake medusa:delayed_job:stop RAILS_ENV=#{rails_env}"
  end

end

before 'deploy:create_symlink', 'deploy:stop'

after 'deploy:create_symlink', 'deploy:link_config'
after 'deploy:create_symlink', 'deploy:precompile_assets'
after 'deploy:create_symlink', 'deploy:start'

