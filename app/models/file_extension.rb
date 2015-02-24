class FileExtension < ActiveRecord::Base
  include FileStatsAggregator
  validates_uniqueness_of :extension, allow_nil: false
  has_many :file_format_profiles_file_extensions_joins, dependent: :destroy
  has_many :file_format_profiles, through: :file_format_profiles_file_extensions_joins
  
  def self.ensure_for_name(filename)
    self.find_or_create_by(extension: self.normalized_extension(filename))
  end

  def self.normalized_extension(filename)
    File.extname(filename).sub(/^\./, '').downcase
  end

  def extension_label
    self.extension.if_blank('<no extension>')
  end

end
