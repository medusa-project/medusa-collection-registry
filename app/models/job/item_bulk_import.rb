require 'fileutils'
class Job::ItemBulkImport < Job::Base
  belongs_to :user
  belongs_to :project

  def self.csv_file_location_root
    File.join(Rails.root, 'tmp', 'item_upload_csv', Rails.env)
  end

  def csv_file_location
    File.join(self.class.csv_file_location_root, "#{self.id}.csv")
  end

  def copy_csv_file(source_path)
    FileUtils.mkdir_p(File.dirname(csv_file_location))
    File.open(csv_file_location, 'wb') do |f|
      File.open(source_path, 'rb') do |g|
        f.write(g.read)
      end
    end
  end

  def enqueue_job
    Delayed::Job.enqueue(self, priority: 10)
  end

  def perform
    parser = ItemCsvParser.from_file(csv_file_location)
    parser.add_items_to_project(project)
    ItemBulkImportMailer.success(user, project, parser.row_count).deliver_now
    File.delete(csv_file_location) if File.exist?(csv_file_location)
  rescue Exception => e
    ItemBulkImportMailer.failure(user, project, e).deliver_now
  end

end
