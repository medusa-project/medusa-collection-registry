class Job::FitsContentTypeBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :content_type

  validates_uniqueness_of :content_type_id, allow_blank: nil
  validates_presence_of :user_id

  BATCH_MAX_SIZE = 100

  def self.create_for(user, content_type)
    if self.find_by(content_type_id: content_type.id)
      nil
    else
      Delayed::Job.enqueue(self.create!(user: user, content_type: content_type), priority: 90)
    end
  end

  def perform
    cfs_files = content_type.cfs_files.where('fits_xml IS NULL').limit(BATCH_MAX_SIZE)
    missing_files = Array.new
    cfs_files.each do |cfs_file|
      unless cfs_file.exists_on_filesystem?
        missing_files << cfs_file
        next
      end
      cfs_file.ensure_fits_xml
    end
  end

end
