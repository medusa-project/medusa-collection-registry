require 'bundler/capistrano'
set :rvm_ruby_string, "1.9.2@medusa-rails3"
require 'rvm/capistrano'

set :production_server, "stribog.grainger.illinois.edu"
set :staging_server, "dagda.grainger.uiuc.edu"

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
set :current, "#{deploy_to}/current"
set :shared, "#{deploy_to}/shared"
set :shared_config, "#{shared}/config"
set :public, "#{current}/public"
set :tomcat_home, "#{home}/tomcat"

set :local_root, File.expand_path('..', File.dirname(__FILE__))

namespace :deploy do
  desc "link shared configuration"
  task :link_config do
    ['database.yml', 'fedora.yml', 'solr.yml'].each do |file|
      run "ln -nfs #{shared_config}/#{file} #{current}/config/#{file}"
    end
  end

end

namespace :akubra_caringo do
  akubra_dir = "#{local_root}/submodules/akubra-caringo"
  jar_name = "akubra-caringo-1.0-jar-with-dependencies.jar"

  desc "build akubra-caringo jar"
  task :build_jar do
    result = system("cd #{akubra_dir} ; mvn package")
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

after 'deploy:update', 'deploy:link_config'
before 'deploy:update_jar', 'medusa:stop_tomcat'
after 'deploy:update_jar', 'medusa:start_tomcat'

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end