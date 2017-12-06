class FileFormatTestReason < ApplicationRecord

  validates :label, uniqueness: true, presence: true
  has_many :file_format_tests_file_format_test_reasons_joins, dependent: :destroy
end