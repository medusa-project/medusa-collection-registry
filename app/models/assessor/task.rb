class Assessor::Task < ApplicationRecord
  belongs_to :cfs_file
  has_many :assessor_responses, class_name: 'Assessor::Response', dependent: :destroy, foreign_key: "assessor_task_id"

  CLUSTER = Settings.assessor.cluster
  ECS_CLIENT = ContainerManager.instance.ecs_client
  MAX_TASK_COUNT = 50
  MAX_BATCH_SIZE = 50

  def initiate_task
    client = ECS_CLIENT
    task = {
      cluster:               CLUSTER,
      count:                 1,
      launch_type:           "FARGATE",
      network_configuration: {
        awsvpc_configuration: {
          subnets:          Settings.assessor.subnets,
          security_groups:  Settings.assessor.security_groups,
          assign_public_ip: "ENABLED"
        }
      },
      overrides:             {
        container_overrides: [
          {
            name:    Settings.assessor.container_name,
            command: ["ruby",
                      "-r",
                      "./lib/assessor.rb",
                      "-e",
                      command_string]
          }
        ]
      },
      platform_version:      Settings.assessor.platform_version,
      task_definition:       Settings.assessor.task_definition
    }
    resp = client.run_task(task)
    puts resp.to_s
    failure_count = resp[:failures].count
    raise StandardError.new("error in Extractor Task for #{cfs_file}: #{resp}") unless failure_count.zero?

    update(sent_at: Time.current)
  end

  def complete?
    return false if self.checksum == true && !subtask_complete?("checksum")

    return false if self.mediatype == true && !subtask_complete?("mediatype")

    return false if self.fits == true && !subtask_complete?("fits")

    true
  end

  def incomplete?
    !complete?
  end

  def subtask_complete?(subtask)
    responses = self.assessor_responses.where(subtask: subtask)
    return false if responses.count.zero?

    responses.each { |response| return true if response.status == "handled" }

    false
  end

  def cfs_file
    CfsFile.find_by(id: self.cfs_file_id)
  end

  def subtask_array_string
    subtasks = Array.new
    subtasks << 'CHECKSUM' if self.checksum == true
    subtasks << 'CONTENT_TYPE' if self.mediatype == true
    subtasks << 'FITS' if self.fits == true
    subtasks.to_s.gsub("\"", "'")
  end

  def command_string

    str_arr = ["Assessor.assess #{subtask_array_string}",
               ", '",
               {"medusa_assessor_task": self.id}.to_json,
               "', '",
               cfs_file.id.to_s,
               "', '",
               cfs_file.storage_root.bucket,
               "', '",
               cfs_file.key,
               "', '",
               cfs_file.fits_result.storage_key,
               "'"]
    str_arr.join
  end

  def self.initiate_task_batch
    unsent = Assessor::Task.where(sent_at: nil)
    return nil unless unsent.count.positive?

    current_task_count = Assessor::Task.current_tasks.count
    return nil unless current_task_count < MAX_TASK_COUNT

    task_capacity = MAX_TASK_COUNT - current_task_count

    to_send = unsent.limit([task_capacity, MAX_BATCH_SIZE].min)
    to_send.map(&:initiate_task)
  end

  def self.current_tasks
    task_list = ECS_CLIENT.list_tasks(cluster: CLUSTER)
    raise StandardError.new("unexpected task_list: #{task_list.to_yaml.to_s}") unless task_list.task_arns

    task_list.task_arns
  end

end
