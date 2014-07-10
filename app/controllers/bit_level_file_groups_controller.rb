class BitLevelFileGroupsController < FileGroupsController

  def create_amazon_backup
    @file_group = BitLevelFileGroup.find(params[:id])
    authorize! :create_amazon_backup, @file_group
    amazon_backup = AmazonBackup.create(user_id: current_user.id,
                                        cfs_directory_id: @file_group.cfs_directory.id,
                                        date: Date.today)
    amazon_backup.request_backup
    redirect_to @file_group
  end

end
