require 'fileutils'
require 'json'

namespace :assessor do

  desc "initiate a batch of tasks"
  task initiate_task_batch: :environment do
    Assessor::Task.initiate_task_batch
  end

  desc "fetch messages"
  task fetch_messages: :environment do
    response = Assessor::Response.fetch_message
    while response != nil
      response = Assessor::Response.fetch_message
    end
  end

  desc "handle fetched messages"
  task handle_fetched_messages: :environment do
    fetched_responses = Assessor::Response.where(status: "fetched").limit(5000)
    fetched_responses.each(&:handle)
  end

  desc "destroy complete task elements"
  task destroy_complete: :environment do
    elements = Assessor::TaskElement.all
    elements.each {|e| e.destroy if e.complete?}
  end

  desc "update from storage"
  task update_missing_file_attributes: :environment do
    CfsFile.all.each do |file|
      file.update_missing_attributes
    end
  end

end