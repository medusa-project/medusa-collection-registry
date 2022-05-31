class Assessor::TaskElement < ApplicationRecord
  belongs_to :cfs_file
  has_many :assessor_responses, class_name: 'Assessor::Response', dependent: :destroy, foreign_key: "assessor_task_id"

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

  def size_category
    b_in_mb = 2**20
    case cfs_file.size/b_in_mb
    when 0..5 then "small"
    when 5..150 then "medium"
    when 150..Float::INFINITY then "large"
    end
  end

  def subtask_array_string
    subtasks = Array.new
    subtasks << 'CHECKSUM' if self.checksum == true
    subtasks << 'CONTENT_TYPE' if self.mediatype == true
    subtasks << 'FITS' if self.fits == true
    subtasks.to_s.gsub("\"", "'")
  end

  def command_ary

    ["[#{subtask_array_string}",
     ", '",
     { "medusa_assessor_task": self.id }.to_json,
     "', '",
     cfs_file.id.to_s,
     "', '",
     cfs_file.storage_root.bucket,
     "', '",
     cfs_file.key,
     "', '",
     cfs_file.fits_result.storage_key,
     "']"]
  end

end
