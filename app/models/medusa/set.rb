module Medusa
  class Set < Medusa::Object
    has_many :members, :property => :is_member_of, :class_name => 'Medusa::Parent'
    belongs_to :subset_of, :property => :is_subset_of, :class_name => 'Medusa::Set'
    has_many :subsets, :property => :is_subset_of, :class_name => 'Medusa::Set'

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