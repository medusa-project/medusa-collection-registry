class Job::VirusScan < Job::Base
  belongs_to :file_group

  def self.create_for(file_group)
    Delayed::Job.enqueue(self.create!(file_group_id: file_group.id), priority: 20)
  end

  def perform
    VirusScan.check_file_group(self.file_group)
  end

  def self.for_repository(repository)
    joins(file_group: {collection: :repository}).where('repositories.id = ?', repository.id)
  end

end
