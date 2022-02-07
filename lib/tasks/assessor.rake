require 'fileutils'
require 'json'

namespace :assessor do

  QUEUE_URL = Settings.message_queues.assessor_to_medusa_url
  SQS = QueueManager.instance.sqs_client
  CLUSTER = Settings.assessor.cluster
  ECS_CLIENT = ContainerManager.instance.ecs_client
  MAX_TASK_COUNT = 49
  MAX_BATCH_COUNT = 9

  def initiate_task_batch
    unsent = Assessor::Task.where(sent_at: nil)
    return nil unless unsent.count.positive?

    current_task_count = Assessor::Task.current_tasks.count
    return nil unless current_task_count < MAX_TASK_COUNT

    task_capacity = MAX_TASK_COUNT - current_task_count
    to_send = unsent.limit([task_capacity, MAX_BATCH_COUNT].min)
    to_send.map(&:initiate_task)
  end

  def fetch_messages
    response = fetch_message
    fetch_messages unless response.nil?
  end

  def fetch_message
    response = SQS.receive_message(queue_url: QUEUE_URL, max_number_of_messages: 1)
    return nil if response.data.messages.count.zero?

    message = JSON.parse(response.data.messages[0].body)
    puts message

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
      subtask = "mediatype"
    else
      subtask = "error"
    end

    task = Assessor::Task.find_by(cfs_file_id: cfs_file_id)
    raise StandardError.new("cannot find task for response: #{message}") if task.nil?

    Assessor::Response.create(assessor_task_id: task.id, subtask: subtask, content: message, status: "fetched")
  end

  def handle_fetched_messages
    fetched_responses = Assessor::Response.where(status: "fetched")
    fetched_responses.each(&:handle)
  end

  def destroy_handled_responses
    Assessor::Response.where(status: "handled").destroy_all
  end

end