module Medusa
  class Set < ActiveFedora::Base
    has_relationship "members", :is_member_of, :inbound => true

    def recursive_delete
      self.members.each {|member| member.recursive_delete}
      self.delete
    end
  end
end