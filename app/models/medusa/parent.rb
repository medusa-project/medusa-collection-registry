module Medusa
  class Parent < Medusa::Object
    belongs_to :member_of, :property => :is_member_of, :class_name => 'Medusa::Set'
    has_many :parts, :property => :is_part_of, :class_name => 'Medusa::Asset'
    has_many :children, :property => :is_child_of, :class_name => 'Medusa::Parent'
    belongs_to :child_of, :property => :is_child_of, :class_name => 'Medusa::Parent'
    has_many :first_child, :property => :is_first_child_of, :class_name => 'Medusa::Parent'
    belongs_to :first_child_of, :property => :is_first_child_of, :class_name => 'Medusa::Parent'
    has_many :next_sibling, :property => :has_previous_sibling, :class_name => 'Medusa::Parent'
    belongs_to :previous_sibling, :property => :has_previous_sibling, :class_name => 'Medusa::Parent'

    def recursive_delete
      self.all_children.reverse.each { |child| child.recursive_delete }
      self.all_parts.each { |part| part.recursive_delete }
      super
    end

    #note - this actually returns 1000000, not necessarily all, but don't know how to get around that right now
    def all_children
      self.children(:rows => 1000000)
    end

    #note - this actually returns 1000000, not necessarily all, but don't know how to get around that right now
    def all_parts
      self.parts(:rows => 1000000)
    end

  end
end