class Assessor::Task < ApplicationRecord

  CLUSTER = Settings.assessor.cluster
  ECS_CLIENT = ContainerManager.instance.ecs_client
  MAX_TASK_COUNT = 50
  MAX_BATCH_SIZE = 50

  attr_accessor :element_group

  def initialize(element_group_ids:)
    self.element_group = Assessor::TaskElement.where(id: element_group_ids)
  end

  def initiate
    client = ECS_CLIENT
    task = {
      cluster: CLUSTER,
      count: 1,
      launch_type: "FARGATE",
      network_configuration: {
        awsvpc_configuration: {
          subnets: Settings.assessor.subnets,
          security_groups: Settings.assessor.security_groups,
          assign_public_ip: "ENABLED"
        }
      },
      overrides: {
        container_overrides: [
          {
            name: Settings.assessor.container_name,
            command: ["ruby",
                      "-r",
                      "./lib/assessor.rb",
                      "-e",
                      "Assessor.assess #{element_group.map(&:command_json)}"]
          }
        ]
      },
      platform_version: Settings.assessor.platform_version,
      task_definition: Settings.assessor.task_definition
    }
    resp = client.run_task(task)
    #puts resp.to_s
    failure_count = resp[:failures].count
    raise StandardError.new("error in Extractor TaskElement for #{cfs_file}: #{resp}") unless failure_count.zero?

    element_group.each do |element|
      element.update(sent_at: Time.current)
    end
  end

  def self.initiate_task_batch
    unsent = Assessor::TaskElement.where(sent_at: nil)
    return nil unless unsent.count.positive?

    current_task_count = Assessor::TaskElement.current_tasks.count
    return nil unless current_task_count < MAX_TASK_COUNT

    task_capacity = MAX_TASK_COUNT - current_task_count

    to_send = unsent.limit([task_capacity, MAX_BATCH_SIZE].min)

    to_send.times do |i|
      task = new Task(Assessor::Task.next_group_ids)
      task.initiate
      sleep 0.1
    end

  end

  def self.next_group_ids
    # assumes set of unset not empty, checked by calling method
    oldest_unsent = Assessor.TaskElement.where(sent_at: nil).first

    b_in_mb = 2**20
    small_max = 5*b_in_mb
    medium_max = 150*b_in_mb
    case oldest_unsent.size_category
    when "small"
      range_q = "c.size < #{small_max.to_s}"
      limit_q = 30.to_s
    when "medium"
      range_q = "c.size > #{small_max.to_s} AND c.size < #{medium_max} "
      limit_q = 5.to_s
    when "large"
      return [oldest_unsent.id]
    else
      raise StandardError.new("Unexpected size category for oldest unset task element.")
    end
    sql = "SELECT t.id FROM assessor_task_elements t, cfs_files c WHERE t.cfs_file_id = c.id AND #{range_q} LIMIT #{limit_q}"
    batch = ActiveRecord::Base.connection.execute(sql)
    return batch.pluck("id")
  end

  def self.current_tasks
    task_list = ECS_CLIENT.list_tasks(cluster: CLUSTER)
    raise StandardError.new("unexpected task_list: #{task_list.to_yaml.to_s}") unless task_list.task_arns

    task_list.task_arns
  end

end