require 'active_support/concern'

module DashboardCommon
  extend ActiveSupport::Concern

  #return a hash with key the id
  #values are hashes with title, collection id, external_id, and title, repository id and title, total file size and count,
  #last backup date (or nil) and last backup completed (or nil)
  def amazon_info(file_groups, backups)
    backup_info_hash = file_group_latest_amazon_backup_hash(backups)
    Hash.new.tap do |hash|
      file_groups.each do |file_group|
        id = file_group[:id].to_i
        hash[id] = file_group
        if backup_info = backup_info_hash[id]
          file_group[:backup_date] = backup_info[:date]
          file_group[:backup_completed] = backup_info[:completed] ? 'Yes' : 'No'
        else
          file_group[:backup_date] = 'None'
          file_group[:backup_completed] = 'N/A'
        end
      end
    end
  end

  #hash from file_group_id to hash with latest backup date and whether it is complete, as judged from the part_count
  #and archive_ids
  def file_group_latest_amazon_backup_hash(backups)
    Hash.new.tap do |hash|
      backups.each do |file_group_id, part_count, archive_ids, date|
        hash[file_group_id.to_i] = HashWithIndifferentAccess.new.tap do |backup_hash|
          backup_hash[:date] = date
          archives = YAML.load(archive_ids)
          backup_hash[:completed] = (archives.present? && (archives.size == part_count.to_i) && archives.none? { |id| id.blank? })
        end
      end
    end
  end

end