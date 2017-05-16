class FileFormatTestReason < ApplicationRecord

  validates :label, uniqueness: true, presence: true

end