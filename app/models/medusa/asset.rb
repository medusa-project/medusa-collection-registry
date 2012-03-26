module Medusa
  class Asset < Medusa::Object
    has_relationship "part_of", :is_part_of

    def recursive_delete
      super
    end
  end

end