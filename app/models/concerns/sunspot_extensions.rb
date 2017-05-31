require 'active_support/concern'

module SunspotExtensions
  extend ActiveSupport::Concern

  module ClassMethods

    def solr_count
      solr_search do
        fulltext ''
      end.total
    end

    #This is to be similar to the clean_index_orphans method provided by Sunspot,
    #except we want it to go both ways, i.e. to both remove orphans and index things
    #that are not indexed yet, and also to work for large indexes on both sides.
    #To do so we'll get ids from both Solr and the DB, write to files, sort the files,
    #then read the files back in keeping track of differences in two sets. Then we can
    #trigger the appropriate action on each set.
    def solr_sync

    end

  end

end