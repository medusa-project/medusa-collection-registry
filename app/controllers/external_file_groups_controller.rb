class ExternalFileGroupsController < FileGroupsController

  def create_bit_level
    external_file_group = ExternalFileGroup.find(params[:id])
    authorize! :update, external_file_group
    if external_file_group.lacks_related_bit_level_file_group?
      bit_level_file_group = external_file_group.create_related_bit_level_file_group
      bit_level_file_group.record_creation_event(current_user)
      redirect_to bit_level_file_group
    else
      flash[:notice] = 'This file group already has a related bit level file group'
      redirect_to external_file_group
    end
  end

end
