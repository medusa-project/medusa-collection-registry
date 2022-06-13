class Assessor::Response < ApplicationRecord
  belongs_to :assessor_task_element, class_name: 'Assessor::TaskElement', foreign_key: 'assessor_task_element_id'
  validates_inclusion_of :subtask, in: %w(checksum content_type fits error), allow_blank: true
  validates_inclusion_of :status, in: %w(fetched processing handled), allow_blank: true

  QUEUE_URL = Settings.message_queues.assessor_to_medusa_url
  SQS = QueueManager.instance.sqs_client
  FITS_STOP_FILE = File.join(Rails.root, 'fits_stop.txt')

  def self.fetch_message
    response = SQS.receive_message(queue_url: QUEUE_URL, max_number_of_messages: 1)
    return nil if response.data.messages.count.zero?

    message = JSON.parse(response.data.messages[0].body)

    SQS.delete_message({queue_url: QUEUE_URL, receipt_handle: response.data.messages[0].receipt_handle})
    file_identifier = message["file_identifier"]
    raise StandardError.new("test assessor message: #{message}") if file_identifier == "test-id"

    cfs_file_id = file_identifier.to_i

    message_type = message["type"]
    case message_type
    when "FITS"
      subtask = "fits"
    when "CHECKSUM"
      subtask = "checksum"
    when "CONTENT_TYPE"
      subtask = "content_type"
    else
      subtask = "error"
    end

    passthrough = JSON.parse(message["passthrough"])

    element = Assessor::TaskElement.find_by(id: passthrough["medusa_assessor_task"])
    raise StandardError.new("cannot find task for response: #{message}") if element.nil?

    Assessor::Response.create(assessor_task_element_id: element.id, subtask: subtask, content: message.to_json, status: "fetched")
  end

  def handle

    self.status = "processing"
    self.save!

    message = JSON.parse(self.content)

    cfs_file = CfsFile.find_by(id: message["file_identifier"])
    raise StandardError.new("no CfsFile found for assessor message: #{self.content}") unless cfs_file

    case self.subtask
    when "fits"
      if cfs_file.fits_result.new?
        #TODO alert and otherwise improve handling
        Rails.logger.warn("fits file not found after success assessor response")
        cfs_file.update_attribute(:fits_serialized, false)
      else
        cfs_file.update_attribute(:fits_serialized, true)
        cfs_file.update_fields_from_fits
      end
    when "checksum"
      new_md5_sum = message["CHECKSUM"]
      cfs_file.set_fixity(new_md5_sum)
      cfs_file.save
    when "content_type"
      new_content_type_name = message["CONTENT_TYPE"]
      cfs_file.update_content_type_from_assessor(new_content_type_name)
    else
      #TODO alert and otherwise improve handling
      Rails.logger.warn("Error response from Medusa Assessor Service: #{self.content}")
    end
    Sunspot.commit
    # TODO maybe delete instead of change status ?
    self.status = "handled"
    self.save!
  end

end
