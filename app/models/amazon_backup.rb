#Create bags to be sent to Amazon Glacier for backup (other code will be
# responsible for requesting creation and for actually uploading)
#Receive the (bit level) file group to back up
#Figure out if there are previous backups and use this information
#to restrict files to back up.
#Make a list of files to back up
#If necessary break the list into pieces for size considerations
#Make bag(s) as backup - use bagit gem
# - create bag b = BagIt::Bag.new(path)
# - add files b.add_file(dest_path, source_path)
# - make manifests b.manifest!
#Extract manifest files from created bags and store

#Record backup in AmazonBackup (relate to filegroup, hold manifest file names, date)

#Config
# - backup registry directory (stores manifests)
# - bag creation dir - where to create the bags - this will
# need significant space, so probably will need to be on our main storage
# - maximum size of bag (environment sensitive so as to enable testing)

#Registry/bag naming format: fg<id>-<dt>-p<part>[.txt|.zip]
require 'fileutils'
class AmazonBackup < ActiveRecord::Base

  serialize :archive_ids
  before_create :initialize_archive_ids_and_date

  belongs_to :cfs_directory
  has_one :job_amazon_backup, :class_name => 'Job::AmazonBackup', :dependent => :destroy
  #This is the user who requested the backup, needed so we can email progress reports
  belongs_to :user
  has_one :workflow_ingest, :class_name => 'Workflow::Ingest'

  #Only allow one backup per day for a file group
  validates_uniqueness_of :date, scope: :cfs_directory_id

  validates_presence_of :user_id, :date

  def initialize_archive_ids_and_date
    self.archive_ids ||= Array.new
    self.date ||= Date.today
  end

  #Return the previous backup for the file group, or nil
  def previous_backup
    self.cfs_directory.amazon_backups.where('date < ?', self.date).order('date desc').first
  end

  #return list of files to back up with sizes, restricting to recently
  #modified files if appropriate
  def backup_file_list
    #If there is a previous backup then only copy things changed since then.
    #Note that we don't try to be too fussy with this - anything actually
    #changed on that date may wind up in two different back even if unchanged
    #since the first backup.
    cutoff_date = self.previous_backup.try(:date)
    Array.new.tap do |file_list|
      directory_walker = TreeRb::DirTreeWalker.new
      file_visitor = TreeRb::TreeNodeVisitor.new do
        on_leaf do |file|
          if cutoff_date.blank? or File.mtime(file) >= cutoff_date
            file_list << [file, File.size(file)]
          end
        end
      end
      directory_walker.run(self.content_directory, file_visitor)
    end
  end

  #partition a list of files to back up into a list of lists
  #respecting the size limit. Set the number of parts.
  #I'd rather do this recursively, but we can't count on tail call optimization
  def partition_file_list(files_and_sizes)
    maximum_size = self.class.maximum_bag_size
    current_size = 0
    current_list = Array.new
    completed_lists = Array.new
    files_and_sizes.each do |file, size|
      if size + current_size < maximum_size
        current_size += size
        current_list << file
      else
        completed_lists << current_list
        current_list = [file]
        current_size = size
      end
    end
    completed_lists << current_list unless current_list.blank?
    self.part_count = completed_lists.size
    self.save!
    return completed_lists
  end

  #given a list of list of files to backup create bags for each one
  def create_bags(file_lists)
    content_path = self.content_directory
    file_lists.each_with_index do |file_list, index|
      bag_dir = self.bag_directory(index + 1)
      FileUtils.rm_rf(bag_dir)
      FileUtils.mkdir_p(bag_dir)
      bag = BagIt::Bag.new(bag_dir)
      file_list.each do |file|
        bag_data_path = file.sub(/^#{content_path}\//, '')
        bag.add_file(bag_data_path, file)
      end
      bag.manifest!
      manifest = self.manifest_file(index + 1)
      FileUtils.rm_rf(manifest)
      FileUtils.copy(File.join(bag_dir, 'manifest-md5.txt'),
                     manifest)
    end
  end

  def make_backup_bags
    self.create_bags(self.partition_file_list(self.backup_file_list))
  end

  def delete_backup_bags_and_manifests
    (1..(self.part_count)).each do |part|
      FileUtils.rm_rf(self.bag_directory(part))
      FileUtils.rm(self.manifest_file(part))
    end
  end

  def request_backup
    self.make_backup_bags
    self.archive_ids = Array.new.tap do |ids|
      self.part_count.times do
        ids << nil
      end
    end
    self.save!
    send_all_backup_request_messages
  end

  def send_all_backup_request_messages
    (1..(self.part_count)).each do |part|
      self.send_backup_request_message(part, self.bag_directory(part))
    end
  end

  def send_backup_request_message(part, directory)
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    exchange = channel.default_exchange
    request = {action: 'upload_directory',
               parameters: {directory: directory, description: self.glacier_description(part)},
               pass_through: {backup_job_class: self.class.to_s, backup_job_id: self.id, part: part, directory: directory}}
    exchange.publish(request.to_json, routing_key: self.class.outgoing_queue, persistent: true)
  end

  def glacier_description(part)
    file_group = self.cfs_directory.file_group
    description = %Q(Amazon Backup Id: #{self.id}
Part: #{part} of #{self.part_count}
Date: #{self.date}
Cfs Directory Id: #{self.cfs_directory.id}
Cfs Directory: #{self.cfs_directory.absolute_path}
    )
    if file_group
      description << %Q(File Group Id: #{file_group.id}
Collection Id: #{file_group.collection.id}
Repository Id: #{file_group.repository.id}
      )
    end
    return description
  end

  def on_amazon_backup_succeeded_message(response)
    part = response.pass_through('part').to_i
    archive_id = response.archive_id
    self.archive_ids[part.to_i - 1] = archive_id
    self.save!
    #remove bag directory for this part
    FileUtils.rm_rf(self.bag_directory(part)) if File.exists?(self.bag_directory(part))
    AmazonMailer.progress(self, part).deliver
    create_backup_completion_event(part)
    if self.completed?
      self.job_amazon_backup.try(:destroy)
      self.workflow_ingest.try(:be_at_end)
    end
  end

  def on_amazon_backup_failed_message(response)
    AmazonMailer.failure(self, response.error_message).deliver
  end

  def on_amazon_backup_unrecognized_message(response)
    AmazonMailer.failure.deliver(self, 'Unrecognized status code in AMQP response')
  end

  def create_backup_completion_event(part)
    file_group = self.cfs_directory.try(:file_group)
    if file_group
      event = Event.new(eventable: file_group, date: Date.today, actor_email: self.user.email)
      if self.completed?
        event.key = 'amazon_backup_completed'
        event.note = "Glacier backup completed. #{self.part_count} part(s) backed up."
      else
        event.key = 'amazon_backup_part_completed'
        event.note = "Glacier backup part number #{part} completed. #{self.completed_part_count} of #{self.part_count} complete."
      end
      event.save!
    end
  end

  def completed_part_count
    self.archive_ids.count { |x| x.present? }
  end

  def completed?
    self.part_count.present? and self.archive_ids.present? and (self.completed_part_count == self.part_count)
  end

  #This is a bit of a misnomer, as a bag may be allowed to have a single
  #file larger than this. It's really the threshold where a new bag is
  #created. In production we don't expect to see anything larger than this
  #anyway; having a smaller size available will be useful for testing though.
  def self.maximum_bag_size
    MedusaRails3::Application.medusa_config['amazon']['maximum_bag_size'].to_i.megabytes
  end

  def self.storage_root
    MedusaRails3::Application.medusa_config['amazon']['bag_storage_root']
  end

  def self.incoming_queue
    MedusaRails3::Application.medusa_config['amazon']['incoming_queue']
  end

  def self.outgoing_queue
    MedusaRails3::Application.medusa_config['amazon']['outgoing_queue']
  end

  def manifest_file(part)
    File.join(self.class.manifest_directory, "#{self.part_file_name(part)}.md5.txt")
  end

  def bag_directory(part)
    File.join(self.class.global_bag_directory, self.part_file_name(part))
  end

  def self.global_bag_directory
    File.join(self.storage_root, 'bags').tap do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def self.manifest_directory
    File.join(self.storage_root, 'manifests').tap do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def content_directory
    self.cfs_directory.absolute_path
  end

  def base_file_name
    "dir_#{self.cfs_directory.path.gsub('/', '_')}-#{self.date.to_time.strftime('%Y%m%d')}"
  end

  def part_file_name(part)
    "#{self.base_file_name}-p#{part}"
  end

end