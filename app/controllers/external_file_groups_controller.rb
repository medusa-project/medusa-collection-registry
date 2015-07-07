class ExternalFileGroupsController < FileGroupsController

  def ingest
    external_file_group = ExternalFileGroup.find(params[:id])
    authorize! :ingest, external_file_group
    if external_file_group.workflow_ingest
      flash[:notice] = 'Ingest already started for this file group.'
    else
      flash[:notice] = 'Ingest started.'
      external_file_group.transaction do
        bit_level_file_group = external_file_group.create_related_bit_level_file_group
        Workflow::Ingest.create_for(current_user, external_file_group, bit_level_file_group)
      end
    end
    redirect_to external_file_group
  end

  def create_bit_level
    external_file_group = ExternalFileGroup.find(params[:id])
    authorize! :update, external_file_group
    if external_file_group.lacks_related_bit_level_file_group?
      bit_level_file_group = external_file_group.create_related_bit_level_file_group
      redirect_to bit_level_file_group
    else
      flash[:notice] = 'This file group already has a related bit level file group'
      redirect_to external_file_group
    end
  end

end
