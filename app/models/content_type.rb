class ContentType < ActiveRecord::Base

  validates_uniqueness_of :name, allow_blank: nil
  validates_numericality_of :cfs_file_count, :cfs_file_size
  has_many :cfs_files

  def update_stats(count_difference, size_difference)
    self.cfs_file_count += count_difference
    self.cfs_file_size += size_difference
    self.save!
  end

  def update_stats_from_db
    self.cfs_file_count = self.cfs_files.count
    self.cfs_file_size = self.cfs_files.sum(:size)
    self.save!
  end

  def self.update_stats_from_db
    self.all.each do |content_type|
      content_type.update_stats_from_db
    end
  end

end
