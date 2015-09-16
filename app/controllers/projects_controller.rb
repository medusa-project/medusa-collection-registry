class ProjectsController < ApplicationController

  before_action :require_logged_in
  before_action :find_project, only: [:show]

  def index
    @projects = Project.order('title ASC')
  end

  def new
    authorize! :create, Project
    @project = Project.new
  end

  def create
    authorize! :create, Project
    @project = Project.new(allowed_params)
    if @project.save
      redirect_to @project
    else
      render 'new'
    end
  end

  def show

  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def allowed_params
    params[:project].permit(:title, :manager_email, :owner_email, :start_date,
                            :status, :specifications, :summary)
  end

end