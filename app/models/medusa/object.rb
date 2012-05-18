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
          solrizer = Solrizer::Fedora::Solrizer.new(:index_full_text => true)
          solrizer.solrize(self)
          try_again = false
        rescue RestClient::RequestTimeout => e
          retries = retries - 1
          Rails.logger.error "SAVE ERROR. GOT REST TIMEOUT. #{retries} RETRIES LEFT."
          raise e if retries == 0
        rescue RestClient::ResourceNotFound => e
          retries = retries - 1
          Rails.logger.error "SAVE ERROR. DIDN'T FIND RESOURCE. #{retries} RETRIES LEFT."
          raise e if retries == 0
        rescue Rubydora::FedoraInvalidRequest => e
          retries = retries - 1
          Rails.logger.error "SAVE ERROR. INVALID FEDORA REQUEST. #{retries} RETRIES LEFT."
          raise e if retries == 0
        ensure
          sleep 5 if try_again
        end
      end
    end

    def self.find_all_with_subclasses
      self.find_all + self.subclasses.collect { |subclass| subclass.find_all_with_subclasses }.flatten
    end

    #not quite aptly named - actually finds a million
    def self.find_all
      self.find(:all, :rows => 1000000)
    end

  end
end