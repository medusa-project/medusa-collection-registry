class Job::Report::Producer < Job::Base
  belongs_to :user
  belongs_to :producer, class_name: '::Producer'

  def self.create_for(params = {})
    Delayed::Job.enqueue(self.create!(params))
  end

  def perform
    csv = ::Report::Producer.new(producer).csv
    ProducerMailer.report(self, csv).deliver_now
  end

end