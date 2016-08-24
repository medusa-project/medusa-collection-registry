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

  def random_cfs_file(args = {})
    if args[:file_group_ids].present?
      query = self.cfs_files.joins(cfs_directory: {root_cfs_directory: :parent_file_group}).where('file_groups.id': args[:file_group_ids])
      count = query.count
      query.order(:name).offset(rand(count)).first
    elsif args[:repository_id].present?
      file_group_ids = Repository.find(args[:repository_id]).collections.collect{|c| c.file_group_ids}.flatten
      self.random_cfs_file(file_group_ids: file_group_ids)
    elsif args[:collection_id].present?
      self.random_cfs_file(file_group_ids: Collection.find(args[:collection_id]).file_group_ids)
    elsif args[:virtual_repository_id].present?
      file_group_ids = VirtualRepository.find(args[:virtual_repository_id]).collections.collect{|c| c.file_group_ids}.flatten
      self.random_cfs_file(file_group_ids: file_group_ids)
    else
      self.cfs_files.order(:name).offset(rand(self.cfs_files.count)).first
    end

  end

end
