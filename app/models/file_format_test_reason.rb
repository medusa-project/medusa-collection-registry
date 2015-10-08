class FileFormatTestReason < ActiveRecord::Base

  validates :label, uniqueness: true, presence: true

end