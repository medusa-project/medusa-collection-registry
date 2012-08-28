class IngestStatusesController < ApplicationController
  def update
    ingest_status = IngestStatus.find(params[:id])
    if ingest_status.update_attributes(params[:ingest_status])
      if request.xhr?
        #do nothing - javascript close the form and leave current values there
      else
        redirect_to edit_collection_path(ingest_status.collection)
      end
    else
      render :status => :bad_request
    end
  end
end
