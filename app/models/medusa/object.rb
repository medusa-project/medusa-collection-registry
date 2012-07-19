module Medusa

  class Object < ActiveFedora::Base
    include ActiveFedora::Relationships

    def recursive_delete
      retries = 5
      deleted = false
      until deleted
        begin
          Rails.logger.info "DELETING CLASS: #{self.class.to_s} PID: #{self.pid}"
          self.delete
          deleted = true
        rescue Exception => e
          retries = retries - 1
          Rails.logger.error "DELETE ERROR. EXCEPTION: #{e.to_s} CLASS: #{self.class.to_s} PID: #{self.pid}"
          if retries < 0
            Rails.logger.error "ABORTING FROM RECURSIVE DELETE"
            raise e
          else
            Rails.logger.error "RETRYING AFTER 5 SECONDS. #{retries} RETRIES REMAINING."
            sleep 5
          end
        end
      end
    end

    #use the fedora config to generate a url where this object can be accessed
    def url
      "#{ActiveFedora.fedora_config[Rails.env.to_sym][:url]}/objects/#{self.pid}"
    end

    #override save in order to try to recover (in one place) from some common problems
    def save
      retries = 10
      try_again = true
      while (try_again)
        begin
          super
          self.index_to_solr
          try_again = false
        rescue RestClient::RequestTimeout, RestClient::ResourceNotFound, Rubydora::FedoraInvalidRequest => e
          retries = retries - 1
          Rails.logger.error "SAVE ERROR. #{e.class.to_s}. #{e.message}. #{retries} RETRIES LEFT."
          raise e if retries == 0
        ensure
          sleep 5 if try_again
        end
      end
    end

    #index this object to solr
    def index_to_solr
      @@solrizer ||= Solrizer::Fedora::Solrizer.new(:index_full_text => true)
      @@solrizer.solrize(self)
    rescue Exception => e
      Rails.logger.error "SAVE: Problem indexing in solr: #{e.class}:#{e.message}"
      @@solrizer = nil
    end

    #remove object with given pid from solr
    def self.remove_from_solr(pid)
      conn = ActiveFedora::SolrService.instance.conn
      conn.delete_by_id(pid)
      conn.commit
    end

    #remove object from solr if present and index again
    def reindex_to_solr
      self.class.remove_from_solr(self.pid)
      self.index_to_solr
    end

    #should work as well as find_all does, but that may have limitations
    def self.find_all_with_subclasses
      self.find_all + self.subclasses.collect { |subclass| subclass.find_all_with_subclasses }.flatten
    end

    #not quite aptly named - actually finds a million
    def self.find_all
      self.find(:all, :rows => 1000000)
    end

  end
end