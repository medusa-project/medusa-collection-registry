class InstitutionsController < ApplicationController
  before_action :require_medusa_user
  before_action :find_institution, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, Institution
    @institutions = Institution.order(:name).all
  end

  def new
    authorize! :create, Institution
    @institution = Institution.new
  end

  def create
    authorize! :create, Institution
    @institution = Institution.new(allowed_params)
    if @institution.save
      redirect_to institution_path(@institution)
    else
      render 'new'
    end
  end

  def show
    authorize! :read, @institution
    @repositories = @institution.repositories
  end

  def edit
    authorize! :update, @institution
  end

  def update
    authorize! :update, @institution
    if @institution.update(allowed_params)
      redirect_to institution_path(@institution)
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @institution
    if @institution.destroy
      redirect_to institutions_path
    else
      redirect_back alert: 'Unable to delete institution', fallback_location: @institution
    end
  end

  protected

  def allowed_params
    params[:institution].permit(:name)
  end

  def find_institution
    @institution = Institution.find(params[:id])
  end

end