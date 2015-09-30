class DashboardController < ApplicationController

  before_action :require_logged_in

  def show
    setup_full_storage_summary
    setup_repository_storage_summary
    setup_red_flags
    setup_file_stats
    setup_amazon
    setup_events
    setup_accrual_jobs
  end

  protected

  def setup_amazon
    @amazon_info = amazon_info
  end

  def setup_file_stats
    @content_type_hashes = ContentType.connection.select_all('SELECT id, name, cfs_file_count, cfs_file_size FROM content_types ORDER BY name ASC').to_hash
    @file_extension_hashes = FileExtension.connection.select_all('SELECT id, extension, cfs_file_count, cfs_file_size FROM file_extensions ORDER BY extension ASC').to_hash
  end

  def setup_red_flags
    @red_flags = RedFlag.order('created_at DESC').includes(:red_flaggable).load
  end

  def setup_full_storage_summary
    @full_storage_summary = Hash.new.tap do |h|
      FileGroup.group(:type).select('type, sum(total_file_size) as size, sum(total_files) as count').each do |row|
        h[row[:type]] = {count: row[:count], size: row[:size]}
      end
    end
    %w(ExternalFileGroup BitLevelFileGroup).each do |type|
      @full_storage_summary[type] ||= {count: 0, size: 0}
    end
  end

  def setup_repository_storage_summary
    @repository_storage_summary = Hash.new.tap do |h|
      FileGroup.joins(collection: :repository).group('type, repositories.id, repositories.title').
          select('type as type, repositories.id as repository_id, repositories.title as repository_title,
                  sum(total_file_size) as size, sum(total_files) as count').
          order('type desc, size desc').each do |row|
        h[row.repository_id] ||= {title: row.repository_title}
        h[row.repository_id][row.type] = {count: row.count, size: row.size}
      end
    end
    %w(ExternalFileGroup BitLevelFileGroup).each do |type|
      @repository_storage_summary.values.each do |summary|
        summary[type] ||= {count: 0, size: 0}
      end
    end
  end

  def setup_events
    @events = Event.order('date DESC').where('updated_at >= ?', Time.now - 7.days).where(cascadable: true).includes(eventable: :parent)
    @scheduled_events = ScheduledEvent.incomplete.order('action_date ASC').includes(scheduled_eventable: :parent)
  end

  #return a hash with key the id
  #values are hashes with title, collection id and title, repository id and title, total file size and count,
  #last backup date (or nil) and last backup completed (or nil)
  def amazon_info
    backup_info_hash = file_group_latest_amazon_backup_hash
    file_group_info_query = <<SQL
    SELECT FG.id, FG.title, FG.total_files, FG.total_file_size, C.id AS collection_id, C.title AS collection_title,
           R.id AS repository_id, R.title AS repository_title
    FROM file_groups FG, collections C, repositories R, cfs_directories CFS
    WHERE FG.type = 'BitLevelFileGroup' AND FG.collection_id = C.id AND c.repository_id = R.id
    AND CFS.parent_type = 'FileGroup' AND CFS.parent_id = FG.id
    ORDER BY FG.id ASC
SQL
    file_groups = FileGroup.connection.select_all(file_group_info_query).to_hash.collect {|h| h.with_indifferent_access}
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
  def file_group_latest_amazon_backup_hash
    query = <<SQL
    SELECT FG.id AS file_group_id, AB.part_count, AB.archive_ids, AB.date FROM amazon_backups AB,
    (SELECT cfs_directory_id, MAX(date) AS max_date FROM amazon_backups GROUP BY cfs_directory_id) ABLU,
    cfs_directories CFS, file_groups FG
    WHERE AB.cfs_directory_id = ABLU.cfs_directory_id AND AB.date = ABLU.max_date AND AB.part_count IS NOT NULL
    AND AB.archive_ids IS NOT NULL AND CFS.id = AB.cfs_directory_id
    AND FG.id = CFS.parent_id AND CFS.parent_type = 'FileGroup'
SQL
    backups = FileGroup.connection.select_rows(query)
    Hash.new.tap do |hash|
      backups.each do |file_group_id, part_count, archive_ids, date|
        hash[file_group_id.to_i] = HashWithIndifferentAccess.new.tap do |backup_hash|
          backup_hash[:date] = date
          archives = YAML.load(archive_ids)
          backup_hash[:completed] = (archives.present? && (archives.size == part_count.to_i) && archives.none? {|id| id.blank?})
        end
      end
    end
  end

  def setup_accrual_jobs
    if ApplicationController.is_ad_admin?(current_user)
      @accrual_jobs = Workflow::AccrualJob.order('created_at asc').all.decorate
    else
      @accrual_jobs = current_user.workflow_accrual_jobs.order('created_at asc').decorate
    end
  end

end