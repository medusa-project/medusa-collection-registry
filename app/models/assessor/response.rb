class Assessor::Response < ApplicationRecord
  belongs_to :assessor_task, class_name: 'Assessor::Task'
  validates_inclusion_of :subtask, in: %w(checksum mediatype fits), allow_blank: false
end
