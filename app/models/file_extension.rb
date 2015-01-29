class FileExtension < ActiveRecord::Base
  include FileStatsAggregator
  validates_uniqueness_of :extension, allow_nil: false

  def self.ensure_for_name(filename)
    extension = File.extname(filename).sub(/^\./, '')
    self.find_or_create_by(extension: extension)
  end

end
