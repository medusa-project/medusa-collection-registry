class Job::Report::Producer < Job::Base
  belongs_to :user
  belongs_to :producer, class_name: '::Producer'

  def self.create_for(params = {})
    job = self.create!(params)
    job.enqueue_job
  end

  def queue
    Settings.delayed_job.short_queue
  end

  def perform
    csv = ::Report::Producer.new(producer).csv
    ProducerMailer.report(self, csv).deliver_now
  end

end