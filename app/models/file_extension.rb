class FileExtension < ApplicationRecord
  include RandomCfsFile

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

  def self.empty
    where(cfs_file_count: 0)
  end

  def self.prune_empty
    empty.each do |file_extension|
      file_extension.destroy!
    end
  end

end
