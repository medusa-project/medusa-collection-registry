module Medusa

  class Object < ActiveFedora::Base
    include ActiveFedora::Relationships

    def recursive_delete
      puts "DELETING class: #{self.class.to_s} pid: #{self.pid}"
      self.delete
    end

    #use the fedora config to generate a url where this object can be accessed
    def url
      "#{ActiveFedora.fedora_config[Rails.env.to_sym][:url]}/objects/#{self.pid}"
    end

  end
end