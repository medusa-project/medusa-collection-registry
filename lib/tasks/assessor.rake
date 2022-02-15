require 'fileutils'
require 'json'

namespace :assessor do

  desc "initiate a batch of tasks"
  task initiate_task_batch: :environment do
    Assessor::Task.initiate_task_batch
  end

  desc "fetch messages from Asessor"
  task fetch_messages: :environment do
    response = Assessor::Response.fetch_message
    fetch_messages unless response.nil?
  end

  desc "handle fetched messages"
  task handle_fetched_messages: :environment do
    fetched_responses = Assessor::Response.where(status: "fetched")
    fetched_responses.each(&:handle)
  end

  desc "destroy handled responses"
  task destroy_handled_responses: :environment do
    Assessor::Response.where(status: "handled").destroy_all
  end

end