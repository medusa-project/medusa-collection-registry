module Medusa
  class Set < Medusa::Object
    has_relationship "members", :is_member_of, :inbound => true
    has_relationship "subset_of", :is_subset_of
    has_relationship "subsets", :is_subset_of, :inbound => true
    has_relationship "parts", :is_part_of, :inbound => true

    def recursive_delete
      self.subsets(:rows => 1000000).each {|subset| subset.recursive_delete}
      self.members(:rows => 1000000).each {|member| member.recursive_delete}
      self.parts(:rows => 1000000).each {|part| part.recursive_delete}
      super
    end
  end

end