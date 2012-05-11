#This is an trivial sort of object for all Medusa Active Fedora object to inherit from.
#I think having this class may possibly be useful when using ActiveFedora - we should always be able to
#find into one of these if need be, I think.
module Medusa
  class GenericObject < ActiveFedora::Base

  end
end