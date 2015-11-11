# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'medusa-collection-registry'
set :repo_url, 'https://github.com/medusa-project/medusa-collection-registry.git'

# Default branch is :master
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :home, '/services/medusa'
set :deploy_to, "#{fetch(:home)}/medusa-cr-capistrano"
set :bin, "#{fetch(:home)}/bin"
set :rails_env, 'production'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/shibboleth.yml config/handle_client.yml config/fits_service.yml
  config/medusa.yml config/smtp.yml config/sunspot.yml config/idb.yml)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :publishing, :stop_application

  task :stop_application do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{fetch(:bin)} ; ./stop-rails"
    end
  end

  task :start_application do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{fetch(:bin)} ; ./start-rails"
    end
  end

  after :publishing, :start_application

end

namespace :sunspot do

  desc "Reindex sunspot indexes"
  task :reindex do
    execute_rake 'sunspot:reindex'
  end

end

namespace :deploy do

  desc "Seed database"
  task :seed do
    execute_rake "db:seed"
  end

end

namespace :medusa do

  desc "Clear rails cache"
  task :clear_rails_cache do
    execute_rake "medusa:rails_cache:clear"
  end
end

def execute_rake(task)
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, task
      end
    end
  end
end