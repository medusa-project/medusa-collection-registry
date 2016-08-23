class Job::FitsContentTypeBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :content_type

  validates_uniqueness_of :content_type_id, allow_blank: nil
  validates_presence_of :user_id

  BATCH_MAX_SIZE = 1000

  def self.create_for(user, content_type)
    if self.find_by(content_type_id: content_type.id)
      nil
    else
      Delayed::Job.enqueue(self.create!(user: user, content_type: content_type), priority: 90, queue: 'initial_assessment')
    end
  end

  def perform
    size = Settings.medusa.fits_batch_size.if_blank(BATCH_MAX_SIZE)
    cfs_files = content_type.cfs_files.where(fits_serialized: false).limit(size)
    missing_files = Array.new
    already_done_files = Array.new
    analyzed_files = Array.new
    cfs_files.each do |cfs_file|
      unless cfs_file.exists_on_filesystem?
        missing_files << cfs_file
        next
      end
      if cfs_file.fits_result.present?
        already_done_files << cfs_file
        next
      end
      cfs_file.ensure_fits_xml
      analyzed_files << cfs_file
    end
    FitsMailer.success(self.user, "Mime type: #{self.content_type.name}", missing_files, already_done_files, analyzed_files).deliver_now
  end

end
