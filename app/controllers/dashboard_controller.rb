class DashboardController < ApplicationController
  include ModelsToCsv

  before_action :require_medusa_user

  def show
    setup_bit_level_storage_summary
    setup_repository_storage_summary
  end

  def running_processes
    render partial: 'running_processes', layout: false
  end

  def file_stats
    @content_type_hashes = ContentType.connection.select_all(content_type_sql)
    @file_extension_hashes = FileExtension.connection.select_all(file_extension_sql)
    respond_to do |format|
      format.html { render partial: 'file_stats_table', layout: false }
      format.csv do
        send_data file_stats_to_csv(@content_type_hashes, @file_extension_hashes), type: 'text/csv', filename: 'file-statistics.csv'
      end
    end
  end

  def file_extension_sql
    <<SQL
    SELECT FE.id AS file_extension_id, FE.extension, FE.cfs_file_count AS file_count, FE.cfs_file_size AS file_size,
      COALESCE(FEC.count, 0) AS tested_count
    FROM file_extensions FE
    LEFT JOIN (SELECT F.file_extension_id, COUNT(*) AS count FROM cfs_files F, file_format_tests FFT WHERE F.id = FFT.cfs_file_id GROUP BY F.file_extension_id) FEC
    ON FE.id = FEC.file_extension_id
    WHERE FE.cfs_file_count > 0
    ORDER BY extension ASC
SQL
  end

  def content_type_sql
    <<SQL
    SELECT CT.id AS content_type_id, CT.name, CT.cfs_file_count AS file_count, CT.cfs_file_size AS file_size,
      COALESCE(CTC.count, 0) AS tested_count
    FROM content_types CT
    LEFT JOIN (SELECT F.content_type_id, COUNT(*) AS count FROM cfs_files F, file_format_tests FFT WHERE F.id = FFT.cfs_file_id GROUP BY F.content_type_id) CTC
    ON CT.id = CTC.content_type_id
    WHERE CT.cfs_file_count > 0
    ORDER BY name ASC
SQL
  end

  def red_flags
    @red_flags = RedFlag.order(created_at: :desc).limit(100).includes(:red_flaggable).load
    render partial: 'shared/red_flags_table', layout: false
  end

  def events
    @events = Event.descending_date.recent.cascadable.includes(eventable: :parent)
    render partial: 'events', layout: false
  end

  def accruals
    if GroupManager.instance.resolver.is_ad_admin?(current_user)
      @accrual_jobs = Workflow::AccrualJob.order(:created_at).all.decorate
    else
      @accrual_jobs = current_user.workflow_accrual_jobs.order(:created_at).decorate
    end
    render partial: 'accruals/accruals', layout: false
  end

  def file_group_deletions
    @workflows = Workflow::FileGroupDelete.all
    render partial: 'file_group_deletes', layout: false
  end

  protected

  def setup_bit_level_storage_summary
    @bit_level_storage_summary = ActiveRecord::Base.connection.select_one("SELECT COALESCE(sum(total_file_size),0) * 1073741824 as size, sum(total_files) as count FROM file_groups WHERE type = 'BitLevelFileGroup'")
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

end