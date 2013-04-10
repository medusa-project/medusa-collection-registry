module Medusa
  class Asset < Medusa::Object
    belongs_to :part_of, :property => :is_part_of, :class_name => 'Medusa::Parent'

    def recursive_delete
      super
    end
  end

end