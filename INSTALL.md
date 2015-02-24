This is a snapshot of how to install medusa-collection-registry. It may be stale, so if you are trying to follow it please update
it as necessary.

#Set up RVM

Install RVM to manage the ruby and gems. The git checkout will have its own .ruby-version and .ruby-gemset.

#Check out medusa-collection-registry

Git clone this project where you want to work with it. cd into the clone to pick up the .ruby-version and .ruby-gemset
and make sure you have the ruby you need and create the gemset.

#Install libraries and gems

We need at least libmagic and postgres (with development packages). So install those, most likely using your
distribution's package manager. Memcached is used for sessions and other caching and will need to be installed (also libmemcached).
RabbitMQ is used for AMQP messaging and should either be installed locally or a remote server configured.

Then bundle install

#Config files

In the config directory if there is a xyz.yml.template but no xyz.yml then copy the template over and edit it
appropriately. For some of these no editing is necessary, but if there are passwords, etc. there may be something to do.

#Create database

Use rake db:create, db:migrate, and db:seed in both the development and test environments.

#Get submodules

git submodule init and git submodule update.

The ruby-fits-server submodule is used to provide a local FITS generating service. The same instance
can be used for all environments. This has FITS as a submodule, so you'll need to go into this directory and once again
git submodule init and git submodule update to get the FITS code.  Also note that this uses its own ruby and gemset, so you'll need
to cd into submodules/ruby-fits-server and do a bundle install (and install the ruby if necessary).
Any system start/stop scripts should also cd into the directory to make sure they pick up the
correct rvm information.

#Start associated processes

rake medusa:delayed_job:start in both environments.

cd into submodules/ruby-fits-server and ./start.sh. This uses its own gemset which you'll
need to install before starting.

#Test

run cucumber and see if it runs and if the tests pass
