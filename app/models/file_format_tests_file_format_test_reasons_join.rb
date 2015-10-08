class FileFormatTestsFileFormatTestReasonsJoin < ActiveRecord::Base
  belongs_to :file_format_test
  belongs_to :file_format_test_reason
end