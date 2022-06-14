class Assessor::TaskElement < ApplicationRecord
  belongs_to :cfs_file
  has_many :assessor_responses, class_name: 'Assessor::Response', dependent: :destroy, foreign_key: 'assessor_task_element_id'

  def complete?

    return false if self.checksum == true && (!subtask_complete?("checksum") || this.cfs_file.md5_sum.nil?)

    return false if self.content_type == true && !subtask_complete?("content_type")

    return false if self.fits == true && (!subtask_complete?("fits") || this.cfs_file.md5_sum.nil?)

    true
  end

  def incomplete?
    !complete?
  end

  def has_errors?
    assessor_responses.where(subtask: "error").count.positive?
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

  def size_category
    b_in_mb = 2**20
    case cfs_file.size/b_in_mb
    when 0..5 then "small"
    when 5..150 then "medium"
    when 150..Float::INFINITY then "large"
    else
      raise StandardError.new("Unexpected size for task element file #{cfs_file.id}.")
    end
  end

  def subtask_array
    subtasks = Array.new
    subtasks << 'CHECKSUM' if self.checksum == true
    subtasks << 'CONTENT_TYPE' if self.content_type == true
    subtasks << 'FITS' if self.fits == true
    subtasks
  end

  def command_json
    {"objective_list" => subtask_array,
     "passthrough" => passthrough_hash.to_json,
     "file_identifier" => cfs_file.id.to_s,
     "object_root" => cfs_file.storage_root.bucket,
     "object_key" => cfs_file.key,
     "fits_key" => cfs_file.fits_result.storage_key}.to_json
  end

  def passthrough_hash
    {"medusa_assessor_task" => self.id}
  end

end
