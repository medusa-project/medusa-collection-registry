class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include SunspotExtensions

end