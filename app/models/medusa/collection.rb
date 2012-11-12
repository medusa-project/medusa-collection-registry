module Medusa
  class Collection < Medusa::Object
    has_relationship 'bit_level_root', :is_bit_level_root_for, :inbound => true
  end
end