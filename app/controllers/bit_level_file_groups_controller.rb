class BitLevelFileGroupsController < FileGroupsController

  def create_amazon_backup
    @file_group = BitLevelFileGroup.find(params[:id])
    authorize! :create_amazon_backup, @file_group
    amazon_backup = AmazonBackup.create(user_id: current_user.id,
                                        cfs_directory_id: @file_group.cfs_directory.id,
                                        date: Date.today)
    Job::AmazonBackup.create_for(amazon_backup)
    redirect_to @file_group
  end

  def bulk_amazon_backup
    authorize! :create_amazon_backup, BitLevelFileGroup
    if params[:bit_level_file_groups].present?
      params[:bit_level_file_groups].each do |file_group_id|
        file_group = BitLevelFileGroup.find(file_group_id)
        amazon_backup = AmazonBackup.new(user_id: current_user.id,
                                         cfs_directory_id: file_group.cfs_directory.id,
                                         date: Date.today)
        amazon_backup.save!
        Job::AmazonBackup.create_for(amazon_backup)
      end
    end
    redirect_to dashboard_path
  end

  def create_initial_cfs_assessment
    @file_group = BitLevelFileGroup.find(params[:id])
    authorize! :create_cfs_fits, @file_group
    if @file_group.is_currently_assessable?
      @file_group.schedule_initial_cfs_assessment
      flash[:notice] = 'CFS simple assessment scheduled'
    else
      flash[:notice] = 'CFS simple assessment already underway for this file group. Please try again later.'
    end
    redirect_to @file_group
  end

  def fixity_check
    @file_group = BitLevelFileGroup.find(params[:id])
    @file_group.transaction do
      @file_group.events.create(key: 'fixity_check_scheduled', date: Date.today, actor_email: current_user.email)
      if Job::FixityCheck.find_by(fixity_checkable: @file_group)
        flash[:notice] = "Fixity check already scheduled for file group id: #{@file_group.id} title: #{@file_group.title}"
      else
        Job::FixityCheck.create_for(@file_group, @file_group.cfs_directory, current_user)
        flash[:notice] = 'Fixity check scheduled'
      end
    end
    redirect_to @file_group
  end

end
