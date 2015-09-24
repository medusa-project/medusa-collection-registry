class FileExtension < ActiveRecord::Base
  validates_uniqueness_of :extension, allow_nil: false
  has_many :file_format_profiles_file_extensions_joins, dependent: :destroy
  has_many :file_format_profiles, through: :file_format_profiles_file_extensions_joins
  validates_numericality_of :cfs_file_count, :cfs_file_size
  has_many :cfs_files

  def self.ensure_for_name(filename)
    self.find_or_create_by(extension: self.normalized_extension(filename))
  end

  def self.normalized_extension(filename)
    File.extname(filename).sub(/^\./, '').downcase
  end

  def extension_label
    self.extension.if_blank('<no extension>')
  end

  def random_cfs_file
    self.cfs_files.order('name').offset(rand(self.cfs_files.count)).first
  end

end
