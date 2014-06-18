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

  belongs_to :cfs_directory

  #Only allow one backup per day for a file group
  validates_uniqueness_of :date, scope: :cfs_directory_id

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
    maximum_size = self.maximum_bag_size
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
    file_lists.each_with_index do |file_list, index|
      bag_dir = self.bag_directory(index + 1)
      FileUtils.mkdir_p(bag_dir)
      bag = BagIt::Bag.new(bag_dir)
      puts bag.bag_dir
      file_list.each do |file|
        bag_data_path = file.sub(/^#{self.cfs_directory.absolute_path}\//, '')
        bag.add_file(bag_data_path, file)
      end
      bag.manifest!
      FileUtils.copy(File.join(bag_dir, 'manifest-md5.txt'),
                     self.manifest_file(index + 1))
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

  #TODO - read from configuration
  def maximum_bag_size
    10.gigabytes
  end

  #TODO - read from configuration
  def storage_root
    return File.join(Rails.root, 'tmp', "amazon-#{Rails.env}")
  end

  def manifest_file(part)
    File.join(self.manifest_directory, "#{self.part_file_name(part)}.md5.txt")
  end

  def bag_directory(part)
    File.join(self.global_bag_directory, self.part_file_name(part))
  end

  def global_bag_directory
    File.join(self.storage_root, 'bags').tap do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def manifest_directory
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