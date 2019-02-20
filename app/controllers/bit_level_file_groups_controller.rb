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

end
