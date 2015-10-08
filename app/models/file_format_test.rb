class FileFormatTest < ActiveRecord::Base

  belongs_to :cfs_file
  belongs_to :file_format_profile
  has_many :file_format_tests_file_format_test_reasons_joins, dependent: :destroy
  has_many :file_format_test_reasons, -> {order 'label asc'}, through: :file_format_tests_file_format_test_reasons_joins

  validates_presence_of :file_format_profile_id, :date
  validates_uniqueness_of :cfs_file_id, allow_blank: false, collection: FileFormatProfile.order(:name)
  validates :tester_email, allow_blank: false, email: true, presence: true

  delegate :name, to: :file_format_profile, prefix: true

  before_save :clear_reasons_on_pass

  def pass_label
    self.pass ? 'Pass' : 'Fail'
  end

  def clear_reasons_on_pass
    file_format_test_reasons.clear if pass
  end

end