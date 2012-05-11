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
      self.children(:rows => 1000000).each {|child| child.recursive_delete}
      self.parts(:rows => 1000000).each {|part| part.recursive_delete}
      super
    end
  end
end