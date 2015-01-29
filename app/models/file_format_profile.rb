class FileFormatProfile < ActiveRecord::Base

  validates_uniqueness_of :name, allow_blank: false

end
