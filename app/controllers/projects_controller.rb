class ProjectsController < ApplicationController

  before_action :require_logged_in
  before_action :find_project, only: [:show, :edit, :update, :destroy]
  include ModelsToCsv

  def index
    @projects = Project.order('title ASC')
    respond_to do |format|
      format.html
      format.csv {send_data projects_to_csv(@projects), type: 'text/csv', filename: 'projects.csv'}
    end
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

  def edit
    authorize! :update, @project
  end

  def update
    authorize! :update, @project
    if @project.update_attributes(allowed_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def show

  end

  def destroy
    authorize! :destroy, @project
    if @project.destroy
      redirect_to projects_path
    else
      redirect_to :back, alert: 'Unknown error deleting project'
    end
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