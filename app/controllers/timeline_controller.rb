class TimelineController < ApplicationController
  include TimelineStats

  before_action :require_medusa_user

  def show
    @yearly_stats = yearly_stats
    @monthly_stats = monthly_stats
    @all_monthly_stats = all_monthly_stats
  end

end