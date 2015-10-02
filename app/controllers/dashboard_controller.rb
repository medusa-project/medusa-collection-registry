class DashboardController < ApplicationController
  include DashboardCommon

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
    file_groups = FileGroup.connection.select_all('SELECT * FROM view_file_group_dashboard_info').to_hash.collect {|h| h.with_indifferent_access}
    backups = FileGroup.connection.select_rows('SELECT * FROM view_file_groups_latest_amazon_backup')
    @amazon_info = amazon_info(file_groups, backups)
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

  def setup_accrual_jobs
    if ApplicationController.is_ad_admin?(current_user)
      @accrual_jobs = Workflow::AccrualJob.order('created_at asc').all.decorate
    else
      @accrual_jobs = current_user.workflow_accrual_jobs.order('created_at asc').decorate
    end
  end

end