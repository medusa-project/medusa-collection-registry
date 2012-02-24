module Medusa
  class Set < ActiveFedora::Base
    has_relationship "members", :is_member_of, :inbound => true
  end
end