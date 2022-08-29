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
    fetched_responses = Assessor::Response.where(status: "fetched")
    fetched_responses.each(&:handle)
  end

  desc "destroy complete task elements"
  task destroy_complete: :environment do
    elements = Assessor::TaskElement.all
    elements.each {|e| e.destroy if e.complete?}
  end

  desc "update from storage"
  task update_from_storage: :environment do
    CfsFile.all.each do |file|
      dirty = false

      if file.md5_sum.nil?
        if file.md5_sum.nil? && self.size < CfsFile.aws_s3_chunk_limit
          file.md5_sum = file.aws_etag
          dirty = true
        end
        if file.fits_result.new?
          Assessor::TaskElement.create(cfs_file_id: self.id,
                                       checksum: false,
                                       content_type: true,
                                       fits: true)
        else
          file = file.update_fields_from_fits
          # this will trigger a checksum assessor task if fits does not have md5_sum
        end

      end
      if file.size.nil?
        file.size = storage_root.size(self.key)
        dirty = true
      end
      if file.mtime.nil?
        file.mtime = storage_root.mtime(self.key)
        dirty = true
      end
      file.save if dirty == true

    end
  end

end