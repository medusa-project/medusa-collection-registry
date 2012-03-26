module Medusa
  class Asset < ActiveFedora::Base
    has_relationship "part_of", :is_part_of

    def recursive_delete
      self.delete
    end
  end

end