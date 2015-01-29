class FileExtension < ActiveRecord::Base
  include FileStatsAggregator
  validates_uniqueness_of :extension, allow_nil: false

  def self.ensure_for_name(filename)
    self.find_or_create_by(extension: self.normalized_extension(filename))
  end

  def self.normalized_extension(filename)
    File.extname(filename).sub(/^\./, '').downcase
  end

end
