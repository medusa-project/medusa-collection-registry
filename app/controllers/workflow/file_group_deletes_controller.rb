class Workflow::FileGroupDeletesController < ApplicationController

  before_action :require_medusa_user

  def admin_decide
    @workflow = Workflow::FileGroupDelete.find(params[:id])
    authorize! :decide, @workflow

  end

end