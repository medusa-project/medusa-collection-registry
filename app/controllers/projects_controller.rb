class ProjectsController < ApplicationController

  before_action :require_logged_in

  def index
    @projects = Project.order('title ASC')
  end

end