class DashboardController < ApplicationController

  before_filter :require_logged_in

  def show
    setup_full_storage_summary
    setup_repository_storage_summary
    setup_red_flags
    setup_events
  end

  protected

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
    ingested_external_storage =
        RelatedFileGroupJoin.joins('JOIN file_groups AS source_file_group ON source_file_group.id = related_file_group_joins.source_file_group_id').
            joins('JOIN file_groups AS target_file_group ON target_file_group.id = related_file_group_joins.target_file_group_id').
            where('source_file_group.type = ?', 'ExternalFileGroup').where('target_file_group.type = ?', 'BitLevelFileGroup').
            select('sum(source_file_group.total_files) as count, sum(source_file_group.total_file_size) as size').load.first
    @full_storage_summary['ExternalUningested'] = {count: @full_storage_summary['ExternalFileGroup'][:count] - (ingested_external_storage.count || 0),
                                                   size: @full_storage_summary['ExternalFileGroup'][:size] - (ingested_external_storage.size || 0)}
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
      @repository_storage_summary.each do |repository_id, summary|
        summary[type] ||= {count: 0, size: 0}
      end
    end
  end

  def setup_events
    @events = Event.order('date DESC').where('updated_at >= ?', Time.now - 7.days).includes(eventable: :parent)
    @scheduled_events = ScheduledEvent.incomplete.order('action_date ASC').includes(scheduled_eventable: :parent)
  end

end