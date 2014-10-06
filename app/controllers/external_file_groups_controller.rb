class ExternalFileGroupsController < FileGroupsController

  def ingest
    external_file_group = ExternalFileGroup.find(params[:id])
    authorize! :ingest, external_file_group
    if external_file_group.workflow_ingest
      flash[:notice] = 'Ingest already started for this file group.'
    else
      flash[:notice] = 'Ingest started.'
      Workflow::Ingest.create!(user: current_user, external_file_group: external_file_group)
    end
    redirect_to external_file_group
  end

end
