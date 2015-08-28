#Helper object to help us compare db and disk versions of a directory and
#produce a report if out of sync
class CfsDirectoryDiskComparison < Object

  attr_accessor :cfs_directory, :files_db_only, :files_disk_only,
                :directories_db_only, :directories_disk_only, :disk_directory_missing

  def initialize(args = {})
    self.cfs_directory = args[:cfs_directory]
    self.files_db_only = args[:files_db_only]
    self.files_disk_only = args[:files_disk_only]
    self.directories_db_only = args[:directories_db_only]
    self.directories_disk_only = args[:directories_disk_only]
    self.disk_directory_missing = args[:disk_directory_missing]
  end

  def out_of_sync?
    [files_db_only, files_disk_only, directories_db_only, directories_disk_only].detect {|collection| collection.present?}
  end

  def disk_directory_missing?
    self.disk_directory_missing
  end
  
  def print_disk_directory_missing
    puts "#{self.cfs_directory.id}:#{self.cfs_directory.absolute_path}"
    puts "MISSING ON DISK"
  end

  def print_report
    puts "#{self.cfs_directory.id}:#{self.cfs_directory.absolute_path}"
    [:files_db_only, :files_disk_only, :directories_db_only, :directories_disk_only].each do |collection|
      diffs = send(collection)
      if diffs.present?
        puts "  #{collection}"
        diffs.each {|diff| puts "    #{diff}"}
      end
    end
  end

end