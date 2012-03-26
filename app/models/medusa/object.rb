module Medusa
  class Object < ActiveFedora::Base
    def recursive_delete
      puts "DELETING class: #{self.class.to_s} pid: #{self.pid}"
      self.delete
    end
  end
end