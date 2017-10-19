This is a snapshot of how to install medusa-collection-registry. It may be stale, so if you are trying to follow it please update
it as necessary.

#Set up ruby

We recommend using something like rbenv or RVM to manage the ruby and gems. 
The git checkout will have its own .ruby-version.

#Check out medusa-collection-registry

Git clone this project where you want to work with it. cd into the clone to pick up the
.ruby-version and .ruby-gemset and make sure you have the ruby you need and 
create the gemset (if using rvm).

#Install libraries and gems

We need at least libmagic and postgres (with development packages). So install those, 
most likely using your distribution's package manager. Memcached is used for sessions 
and other caching and will need to be installed (also libmemcached).
RabbitMQ is used for AMQP messaging and should either be installed 
locally or a remote server configured. ClamAV is used for 
virus scanning. VIPS is used for image processing (and any 
subdependencies you want to install).  In development PhantomJS is needed for some tests. 
Postgresql is used as the database and postgres specific functionality
is used (plpgsql language triggers, etc.), so it would be work to port to a 
different database. lmdb is used in the process to check if directory syncs have happened correctly.

Solr and FITS are also used, but for development purposes the Solr installed by sunspot should suffice, 
and FITS is installed by a git submodule.

Then bundle install. It should be obvious if any dependencies are missing.

#Config files

In the config directory if there is a xyz.yml.template but no xyz.yml then copy the template over and edit it
appropriately. database.yml, sunspot.yml, and settings/<env>.local.yml (using settings/development.yml
as a template) will definitely need to be done. 

Most of the config is done in settings.yml and the environment files in settings/<env>.yml. 
These are used with the Config gem. <env>.local.yml is where you probably want
to customize the most for server settings, passwords, etc. 
settings.yml itself may be customized, but needn't be.

database.yml performs its normal role for rails applications. Note again that there are Postgresql
specific pieces of code, so Postgres is necessary.


#Create database

Use rake db:create, db:migrate, and db:seed in both the development and test environments. Alternately, load the db
schema with rake db:schema:load and then seed. Note that in addition to migrations there is also some
sql in db/views that db:seed loads up and that is used in the application.

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

cd into submodules/ruby-fits-server, install the bundle, and ./start.sh. 

#Test

run cucumber and see if it runs and if the tests pass
