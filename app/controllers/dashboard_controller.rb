class DashboardController < ApplicationController

  before_filter :require_logged_in

  def show
    setup_storage_summary
    setup_red_flags
    setup_events
  end

  protected

  def setup_red_flags
    @red_flags = RedFlag.order('created_at DESC').includes(:red_flaggable).load
  end

  #TODO - I bet we can do this more efficiently - it'd be easy with SQL, but we can probably do it with arel as well.
  def setup_storage_summary
    @storage_summary = []
    Repository.includes(:collections => {:file_groups => :target_file_groups}).each do |repository|
      external_file_groups = repository.collections.collect { |c| c.file_groups.select { |fg| fg.is_a?(ExternalFileGroup) } }.flatten
      uningested_external_file_groups = external_file_groups.reject do |fg|
        fg.target_file_groups.detect { |target| target.is_a?(BitLevelFileGroup) }
      end
      bit_level_file_groups = repository.collections.collect { |c| c.file_groups.select { |fg| fg.is_a?(BitLevelFileGroup) } }.flatten
      @storage_summary << Hash.new.tap do |h|
        h[:repository] = repository
        h[:external_file_count] = external_file_groups.collect { |fg| fg.file_count || 0 }.sum
        h[:external_size] = external_file_groups.collect { |fg| fg.file_size || 0 }.sum
        h[:uningested_file_count] = uningested_external_file_groups.collect { |fg| fg.file_count || 0 }.sum
        h[:uningested_size] = uningested_external_file_groups.collect { |fg| fg.file_size || 0 }.sum
        h[:bit_level_file_count] = bit_level_file_groups.collect { |fg| fg.file_count || 0 }.sum
        h[:bit_level_file_size] = bit_level_file_groups.collect { |fg| fg.file_size || 0 }.sum
      end
    end
    @storage_summary.sort! { |a, b| b[:external_size] <=> a[:external_size] }
  end

  def setup_events
    @events = Event.order('date DESC').where('updated_at >= ?', Time.now - 7.days).includes(:eventable => :parent)
    @scheduled_events = ScheduledEvent.incomplete.order('action_date ASC').includes(:scheduled_eventable => :parent)
  end

end