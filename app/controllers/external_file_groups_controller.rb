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

end
