require 'active_support/concern'

module FileStatsAggregator
  extend ActiveSupport::Concern

  included do
    validates_numericality_of :cfs_file_count, :cfs_file_size
    has_many :cfs_files
  end

  module ClassMethods
    def update_stats_from_db
      self.find_each do |aggregator|
        aggregator.update_stats_from_db
      end
    end
  end

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

end