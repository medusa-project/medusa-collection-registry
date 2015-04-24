class Job::FitsFileExtensionBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :file_extension

  validates_uniqueness_of :file_extension_id, allow_blank: false
  validates_presence_of :user_id

  BATCH_MAX_SIZE = 100

  def self.create_for(user, file_extension)
    if self.find_by(file_extension_id: file_extension.id)
      nil
    else
      Delayed::Job.enqueue(self.create!(user: user, file_extension: file_extension), priority: 90, queue: 'initial_assessment')
    end
  end

  def perform
    cfs_files = file_extension.cfs_files.where('fits_xml IS NULL').limit(BATCH_MAX_SIZE)
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
