require 'rake'
require 'open3'

namespace :amazon do

  #Note that for this to work the medusa-glacier server must also be configured to
  #accept delete requests.
  desc 'Delete old amazon backups - FOR TEST SERVER ONLY'
  task delete_old_backups: :environment do
    old_backups = AmazonBackup.all.select {|ab| ab.updated_at < Date.today - 91.days}
    old_backups.each {|backup| backup.delete_archives_and_self}
  end

  desc 'Show information about bit level file groups that have no amazon backup'
  task show_unbackedup: :environment do
    file_groups = unbackedup_bit_level_file_groups
    puts "#{file_groups.count} bit level file groups have no amazon backup"
    puts "#{file_groups.collect(&:total_file_size).sum} GB of content is represented"
  end

  desc 'Schedule backups for bit level file groups that have no amazon backup'
  task backup_unbackedup: :environment do

  end

  desc 'Show bit level file groups that may need a new amazon backup'
  task show_possibly_stale: :environment do
    file_groups = stale_bit_level_file_groups
    puts "#{file_groups.count} bit level file groups may have stale amazon backups (of #{BitLevelFileGroup.count} total)"
    puts "#{file_groups.collect(&:total_file_size).sum} GB of content is represented - some of this may already be backed up"
  end

  desc 'Schedule backups for bit level file groups that may need a new amazon backup'
  task backup_possibly_stale: :environment do

  end

  #This uses heuristic methods and is not definite, but anything it returns should be reassessed
  desc 'Show bit level file groups that need a new initial assessment'
  task show_needing_reassessment: :environment do
    BitLevelFileGroup.order(:id).all.each do |fg|
      puts "#{fg.id}:#{file_count_difference(fg)}"
    end
    puts "DONE"
  end

  def unbackedup_bit_level_file_groups
    BitLevelFileGroup.all.select {|fg| fg.amazon_backups.blank?}
  end

  def stale_bit_level_file_groups
    BitLevelFileGroup.all.select{|fg| stale?(fg)}
  end

  def stale?(file_group)
    last_backup = file_group.last_amazon_backup
    return false unless last_backup
    cutoff_time = last_backup.created_at
    cfs_directory = file_group.cfs_directory
    latest_cfs_file_creation = CfsFile.where(cfs_directory_id: cfs_directory.recursive_subdirectory_ids).maximum(:created_at)
    return latest_cfs_file_creation > cutoff_time
  end

  def file_count_difference(file_group)
    db_count = file_group.total_files
    fs_count, status = Dir.chdir(file_group.cfs_directory.absolute_path) do
      Open3.capture2('find . -type f | wc -l')
    end
    return fs_count.to_i - db_count
  rescue Exception => e
    return "error: #{e}"
  end

end
