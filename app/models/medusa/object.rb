module Medusa

  class Object < ActiveFedora::Base
    include ActiveFedora::Relationships

    def recursive_delete
      retries = 5
      deleted = false
      until deleted
        begin
          puts "DELETING class: #{self.class.to_s} pid: #{self.pid}"
          self.delete
          deleted = true
        rescue Exception => e
          retries = retries - 1
          puts "Exception #{e.to_s} deleting #{self.class.to_s} pid: #{self.pid}"
          if retries < 0
            puts "Aborting from recursive delete"
            raise e
          else
            puts "Retrying after 5 seconds. #{retries} retries remaining."
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
          puts "Got REST timeout. #{retries} retries left."
          raise e if retries == 0
        rescue RestClient::ResourceNotFound => e
          retries = retries - 1
          puts "Didn't find resource. #{retries} retries left."
          raise e if retries == 0
        rescue Rubydora::FedoraInvalidRequest => e
          retries = retries - 1
          puts "Invalid Fedora Request. #{retries} retries left."
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