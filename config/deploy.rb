require 'bundler/capistrano'
set :rvm_ruby_string, "1.9.3-p194@medusa-rails3"
require 'rvm/capistrano'
require 'auto_html/capistrano'

set :production_server, "stribog.grainger.illinois.edu"
set :staging_server, "dagda.grainger.uiuc.edu"
default_run_options[:shell] = '/bin/bash -l'

task :production do
  role :web, production_server
  role :app, production_server
  role :db, production_server, :primary => true
end

task :staging do
  role :web, staging_server
  role :app, staging_server
  role :db, staging_server, :primary => true
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
set :tomcat_home, "#{home}/tomcat"

set :local_root, File.expand_path('..', File.dirname(__FILE__))

namespace :deploy do
  desc "link shared configuration"
  task :link_config do
    ['database.yml', 'fedora.yml', 'solr.yml', 'shibboleth.yml', 'handle_client.yml',
     'dx.yml', 'fits_service.yml'].each do |file|
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
  task :restart, :roles => :app, :except => {:no_release => true} do
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

namespace :akubra_caringo do
  akubra_dir = "#{local_root}/submodules/akubra-caringo"
  jar_name = "akubra-caringo-1.0-jar-with-dependencies.jar"

  desc "build akubra-caringo jar"
  task :build_jar do
    result = system("cd #{akubra_dir} ; mvn package -DskipTests")
    unless result
      puts "Build of akubra-caringo jar failed"
      exit(result)
    end
  end

  desc "upload akubra-caringo jar"
  task :upload_jar do
    run "mkdir -p #{shared}/java"
    upload("#{akubra_dir}/target/#{jar_name}", "#{shared}/java/#{jar_name}")
    #put "hi", "#{shared}/java/test.txt"
  end

  desc "copy the akubra-caringo jar to the fedora lib directory"
  task :install_jar do
    run "cp -f #{shared}/java/#{jar_name} #{tomcat_home}/webapps/fedora/WEB-INF/lib/#{jar_name}"
  end

  desc "Update the akubra-caringo jar"
  task :update_jar do
    find_and_execute_task('akubra_caringo:build_jar')
    find_and_execute_task('akubra_caringo:upload_jar')
    find_and_execute_task('akubra_caringo:install_jar')
  end
end
before 'akubra_caringo:install_jar', 'medusa:stop_tomcat'
after 'akubra_caringo:install_jar', 'medusa:start_tomcat'

namespace :medusa do
  desc "stop tomcat"
  task :stop_tomcat do
    run "~/bin/stop-tomcat"
  end

  desc "start tomcat"
  task :start_tomcat do
    run "~/bin/start-tomcat"
  end

  desc "restart tomcat"
  task :restart_tomcat do
    find_and_execute_task('medusa:stop_tomcat')
    find_and_execute_task('medusa:start_tomcat')
  end

end

before 'deploy:create_symlink', 'deploy:stop'

after 'deploy:create_symlink', 'deploy:link_config'
after 'deploy:create_symlink', 'deploy:precompile_assets'
after 'deploy:create_symlink', 'deploy:start'

before 'deploy:update_jar', 'medusa:stop_tomcat'
after 'deploy:update_jar', 'medusa:start_tomcat'
