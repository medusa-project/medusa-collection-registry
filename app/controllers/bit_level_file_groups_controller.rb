class BitLevelFileGroupsController < FileGroupsController

  def create_initial_cfs_assessment
    @file_group = BitLevelFileGroup.find(params[:id])
    @file_group.ensure_cfs_directory
    authorize! :create_cfs_fits, @file_group
    if @file_group.is_currently_assessable?
      @file_group.schedule_initial_cfs_assessment
      flash[:notice] = 'CFS simple assessment scheduled'
    else
      flash[:notice] = 'CFS simple assessment already underway for this file group. Please try again later.'
    end
    redirect_to @file_group
  end

  def timeline
    @file_group = BitLevelFileGroup.find(params[:id])
    @file_group.ensure_cfs_directory
    @directory = @file_group.cfs_directory
    timeline = Timeline.new(object: @directory)
    @yearly_stats = timeline.yearly_stats
    @monthly_stats = timeline.monthly_stats
    @all_monthly_stats = timeline.all_monthly_stats
  end

end
