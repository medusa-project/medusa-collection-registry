module Medusa
  class Parent < Medusa::Object
    has_relationship "member_of", :is_member_of
    has_relationship "parts", :is_part_of, :inbound => true
    has_relationship "children", :is_child_of, :inbound => true
    has_relationship "child_of", :is_child_of
    has_relationship "first_child", :is_first_child_of, :inbound => true
    has_relationship "first_child_of", :is_first_child_of
    has_relationship "next_sibling", :has_previous_sibling, :inbound => true
    has_relationship "previous_sibling", :has_previous_sibling

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