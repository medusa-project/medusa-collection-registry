module Medusa
  class Part < ActiveFedora::Base
    has_relationship "part_of", :is_part_of
  end
end