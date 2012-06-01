module Medusa
  class Set < Medusa::Object
    has_relationship "members", :is_member_of, :inbound => true
    has_relationship "subset_of", :is_subset_of
    has_relationship "subsets", :is_subset_of, :inbound => true
    has_relationship "parts", :is_part_of, :inbound => true

    def recursive_delete
      self.all_subsets.each { |subset| subset.recursive_delete }
      self.all_members.each { |member| member.recursive_delete }
      self.all_parts.each { |part| part.recursive_delete }
      super
    end

    #note - this actually returns 1000000, not necessarily all, but don't know how to get around that right now
    def all_subsets
      self.subsets(:rows => 1000000)
    end

    #note - this actually returns 1000000, not necessarily all, but don't know how to get around that right now
    def all_members
      self.members(:rows => 1000000)
    end

    #note - this actually returns 1000000, not necessarily all, but don't know how to get around that right now
    def all_parts
      self.parts(:rows => 1000000)
    end

  end

end