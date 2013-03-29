This is a snapshot of how to install medusa-rails3. It may be stale, so if you are trying to follow it please update
it as necessary.

#Set up RVM

Install RVM to manage the ruby and gems. The git checkout will have its own .rvmrc.

#Check out medusa-rails3

Git clone this project where you want to work with it. cd into the clone to pick up the .rvmrc and make sure
you have the ruby you need and create the gemset.

#Install libraries and gems

We need at least libmagic and postgres (with development packages). So install those, most likely using your
distribution's package manager.

Then bundle install

#Config files

In the config directory if there is a xyz.yml.template but no xyz.yml then copy the template over and edit it
appropriately. For some of these no editing is necessary, but if there are passwords, etc. there may be something to do.

#Create database

Use rake db:create, db:migrate, and db:seed in both the development and test environments.

#Get submodules

git submodule init and git submodule update.

The hydra-jetty submodule is used to provide a real solr/fedora for development and testing.

The ruby-fits-server submodule is used to provide a local FITS generating service. The same instance
can be used for all environments. To use it you'll need to install FITS locally and set FITS_HOME
to the installation directory. Also note that this uses its own ruby and gemset, so you'll need
to cd into submodules/ruby-fits-server and do a bundle install (and install the ruby if necessary).
Any system start/stop scripts should also cd into the directory to make sure they pick up the
correct rvm information.

#Install Jetty

rake jetty:install, in both the development and test environments

#Start associated processes

rake jetty:start and rake medusa:delayed_job:start in both environments.

cd into submodules/ruby-fits-server and ./start.sh

#Test

run cucumber and see if it runs and if the tests pass
