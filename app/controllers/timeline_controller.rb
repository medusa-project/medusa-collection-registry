class TimelineController < ApplicationController

  before_action :require_medusa_user

  def show
    timeline = Timeline.new
    @yearly_stats = timeline.yearly_stats
    @monthly_stats = timeline.monthly_stats
    @all_monthly_stats = timeline.all_monthly_stats
  end

end