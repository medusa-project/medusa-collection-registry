class ContentType < ActiveRecord::Base
  include FileStatsAggregator

  validates_uniqueness_of :name, allow_blank: nil

end
