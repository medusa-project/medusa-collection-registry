module Medusa
  class Set < ActiveFedora::Base
    has_relationship :is_member_of, :inbound => true
  end
end