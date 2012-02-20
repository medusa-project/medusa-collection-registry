module Medusa
  class Parent < ActiveFedora::Base
    has_relationship "member_of", :is_member_of
    has_relationship "part_of", :is_part_of, :inbound => true
  end
end