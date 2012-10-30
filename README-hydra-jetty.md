For convenience in developing and testing we've puts some hooks in to allow the hydra-jetty distribution of
fedora/solr to be used.

To initialize this do:

    git submodule init

This will clone hydra-jetty into fedora/hydra-jetty. We don't use this directly, but copy it into a separate directory
under fedora depending on the environment. In order to create a copy set RAILS_ENV and then

    rake jetty:install


This will make a file system copy of the directory and fix up the config file to run on port 18983 for development
and 28983 for test. For any other environment the default port 8983 is used. The config/fedora.xml and config/solr.xml
files are set to use this convention. The copy will be in fedora/hydra-jetty-<env>. Since we are making a copy for each
environment we always use the development core in solr - we don't need the test core (which hydra-jetty employs to allow
both in the same core).


You can start or stop the jetty for RAILS_ENV by using the jetty:start and jetty:stop rake tasks. The pid of the jetty
 is in fedora/hydra-jetty-<env>/fedora.pid. As a byproduct of the way it is started a daemons.rb.pid file may also
 appear in your directory tree, but you can safely ignore or delete this (and it is gitignored).


You can purge all objects for the environment by using the jetty:delete_objects rake task.


Cucumber is set to delete all objects before tests are run.


Note that some of the (dangerous) rake tasks will not execute unless you set FORCE=true on the command line (or in the
environment). You'll be notified if this is a problem. This only applies in the development and production environments.