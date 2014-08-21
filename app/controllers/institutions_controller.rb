class InstitutionsController < ApplicationController
  before_filter :require_logged_in

  def index
    authorize! :manage, Institution
    @institutions = Institution.order('name ASC').all
  end

end