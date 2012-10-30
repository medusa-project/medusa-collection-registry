require 'rake'
require 'nokogiri'
require 'fileutils'
require 'daemons'

namespace :jetty do 
  desc 'Remove old hydra jetty for this environment'
  task :delete => [:environment, :stop] do
    check_environment
    puts "Removing #{Rails.env} jetty."
    system("rm -rf #{jetty_path}") if Dir.exist?(jetty_path)
  end

  desc 'Copy new hydra jetty for this environment'
  task :copy => :environment do
    if Dir.exist?(jetty_path)
      puts "Hydra jetty already exists at #{jetty_path}. Aborting."
      exit 0
    end
    puts "Copying jetty for #{Rails.env}. This may take a moment."
    system("cp -a #{jetty_template_path} #{jetty_path}")
    puts "Copied jetty for #{Rails.env}"
  end

  desc 'Reinstall hydra jetty for this environment'
  task :reinstall => [:delete, :copy] do
    fix_jetty_port
#    write_scripts
  end

  desc 'Start jetty for this environment'
  task :start => :environment do
    puts "Starting #{Rails.env} jetty."    
    Daemons.daemonize
    Dir.chdir(jetty_path)
    File.open(pid_file, 'w') {|f| f.puts Process.pid}
    exec 'java -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:PermSize=64M -XX:MaxPermSize=128M -jar start.jar'
  end

  desc 'Stop jetty for this environment'
  task :stop => :environment do
    puts "Stopping #{Rails.env} jetty."
    if File.exists?(pid_file)
      begin
        pid = File.read(pid_file).to_i
        puts "Killing jetty process pid: #{pid}."
        system("kill #{pid}")
        puts "Jetty process pid: #{pid} killed."
        FileUtils.rm_f(pid_file)
      rescue Exception
        puts "Problem killing jetty"
      end
    else
      puts "#{pid_file} not found. Jetty is not running or is unknown."
    end
  end

  desc 'Restart jetty for this environment'
  task :restart => [:stop, :start] do
    
  end
end

#only do the task if the env variable FORCE=true if in the development
#or production environment
def check_environment
  if ['production', 'development'].include?(Rails.env) and
      ENV['FORCE'] != 'true'
    puts "*** You must set FORCE=true to run this rake task in the #{Rails.env } environment ***"
    exit 0
  end
end

def jetty_path
  File.join(Rails.root, 'fedora', "hydra-jetty-#{Rails.env}")
end

def jetty_template_path
  File.join(Rails.root, 'fedora', 'hydra-jetty')
end

def jetty_config_file
  File.join(jetty_path, 'etc', 'jetty.xml')
end

def jetty_start_jar
  File.join(jetty_path, 'start.jar')
end

def start_script_file
  File.join(jetty_path, 'start.sh')  
end

JETTY_PORT_MAP = {'production' => '8983', 'development' => '18983', 'test' => '28983'}
def jetty_port
  port = JETTY_PORT_MAP[Rails.env]
  unless port
    puts "Jetty port not defined in JETTY_PORT_MAP for this #{Rails.env} environment."
    exit 0
  end
  return port
end

def pid_file
  File.join(jetty_path, 'fedora.pid')
end

def fix_jetty_port
  config = Nokogiri::XML::Document.parse(File.read(jetty_config_file))
  config.at_css('SystemProperty[name="jetty.port"]')['default'] = jetty_port
  File.open(jetty_config_file, 'w') {|f| f.puts(config.to_xml)}
end

def write_scripts
  File.open(start_script_file, 'w') do |f|
    f. puts <<-SCRIPT
#!/bin/bash

echo $$ > fedora.pid

exec java -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:PermSize=64M -XX:MaxPermSize=128M -jar start.jar
SCRIPT
  end
  File.chmod(0755, start_script_file)
end

