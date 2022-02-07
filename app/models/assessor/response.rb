class Assessor::Response < ApplicationRecord
  belongs_to :assessor_task, class_name: 'Assessor::Task'
  validates_inclusion_of :subtask, in: %w(checksum mediatype fits error), allow_blank: true
  validates_inclusion_of :status, in: %w(fetched processing handled), allow_blank: true

  QUEUE_URL = Settings.message_queues.assessor_to_medusa_url
  SQS = QueueManager.instance.sqs_client
  FITS_STOP_FILE = File.join(Rails.root, 'fits_stop.txt')

  def handle

    self.status = "processing"
    self.save!

    cfs_file = CfsFile.find_by(id: self.cfs_file_id)
    raise StandardError.new("no CfsFile found for assessor message: #{self.content}") unless cfs_file

    case self.subtask
    when "fits"
      fits_result = FitsResult.new(cfs_file: cfs_file)
      raise StandardError.new("fits file not found Assessor::Response #{self.id.to_s}") if fits_result.new?

      cfs_file.update_attribute(:fits_serialized, true)
      cfs_file.update_fields_from_fits
    when "checksum"
      new_md5_sum = self.content["CHECKSUM"]
      cfs_file.update_md5_sum_from_assessor(new_md5_sum)
    when "mediatype"
      new_content_type_name = self.content["CONTENT_TYPE"]
      cfs_file.update_content_type_from_assessor(new_content_type_name)
    else
      raise StandardError.new("Error response from Medusa Assessor Service: #{self.content}")
    end
    sunspot.commit
    # maybe delete instead of change status ?
    self.status = "handled"
    self.save!
  end

end
