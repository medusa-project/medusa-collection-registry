class Assessor::Response < ApplicationRecord
  belongs_to :assessor_task, class_name: 'Assessor::Task'
  validates_inclusion_of :subtask, in: %w(checksum mediatype fits), allow_blank: true

  QUEUE_URL = Settings.message_queues.assessor_to_medusa_url
  SQS = QueueManager.instance.sqs_client

  def self.fetch
    response = SQS.receive_message(queue_url: QUEUE_URL, max_number_of_messages: 1)
    return nil if response.data.messages.count.zero?

    message = JSON.parse(response.data.messages[0].body)
    puts message

    SQS.delete_message({queue_url: QUEUE_URL, receipt_handle: response.data.messages[0].receipt_handle})
    file_identifier = message["file_identifier"]
    raise StandardError.new("test assessor message: #{message}") if file_identifier == "test-id"

    cfs_file_id = file_identifier.to_i
    message_type = message["type"]
    subtask = "fits" if message_type == "FITS"
    subtask = "checksum" if message_type == "CHECKSUM"
    subtask = "mediatype" if message_type == "CONTENT_TYPE"
    raise StandardError.new("missing type for assessor message: #{message}") if subtask.nil?
    task = Assessor::Task.find_by(cfs_file_id: cfs_file_id)
    raise StandardError.new("cannot find task for response: #{message}")

    Assessor::Response.create(assessor_task_id: task.id, subtask: subtask, content: message)
  end

  def handle
    cfs_file = CfsFile.find_by(id: self.cfs_file_id)
    raise StandardError.new("no CfsFile found for assessor message: #{message}") unless cfs_file
    # TODO actually handle response
  end

end
