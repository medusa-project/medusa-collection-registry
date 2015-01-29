class ContentType < ActiveRecord::Base
  include FileStatsAggregator

  validates_uniqueness_of :name, allow_blank: nil
  has_many :file_format_profiles_content_types_joins, dependent: :destroy
  has_many :file_format_profiles, through: :file_format_profiles_content_types_joins

end
