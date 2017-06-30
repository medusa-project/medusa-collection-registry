class ContentType < ApplicationRecord
  include RandomCfsFile

  validates_uniqueness_of :name, allow_blank: nil
  has_many :file_format_profiles_content_types_joins, dependent: :destroy
  has_many :file_format_profiles, through: :file_format_profiles_content_types_joins
  validates_numericality_of :cfs_file_count, :cfs_file_size
  has_many :cfs_files

  def self.prune_empty
    where(cfs_file_count: 0).each do |content_type|
      content_type.destroy
    end
  end

end
