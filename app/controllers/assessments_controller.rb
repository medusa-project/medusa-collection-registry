class AssessmentsController < ApplicationController

  before_action :require_medusa_user
  before_action :find_assessment_and_assessable, only: [:destroy, :show, :edit, :update]
  helper :assessments
  decorates_assigned :assessable

  def destroy
    authorize! :destroy_assessment, @assessable
    @assessment.destroy
    redirect_to @assessable
  end

  def show

  end

  def edit
    authorize! :update_assessment, @assessable
  end

  def update
    authorize! :update_assessment, @assessable
    if @assessment.update(allowed_params)
      redirect_to assessment_path(@assessment)
    else
      render 'edit'
    end
  end

  def new
    klass = assessable_class(params)
    @assessable = klass.find(params[:assessable_id])
    authorize! :create_assessment, @assessable
    @assessment = Assessment.new
    @assessment.author = Person.find_or_create_by(email: current_user.email)
    @assessment.assessable = @assessable
  end

  def create
    klass = assessable_class(params[:assessment])
    @assessable = klass.find(params[:assessment].delete(:assessable_id))
    authorize! :create_assessment, @assessable
    @assessment = @assessable.assessments.build(allowed_params)
    if @assessment.save
      redirect_to assessment_path(@assessment)
    else
      render 'new'
    end
  end

  protected

  def find_assessment_and_assessable
    @assessment = Assessment.find(params[:id])
    @assessable = @assessment.assessable
  end

  def assessable_class(hash)
    assessable_type_name = hash.delete(:assessable_type)
    case assessable_type_name
      when 'Collection'
        Collection
      when 'FileGroup', 'ExternalFileGroup', 'BitLevelFileGroup'
        FileGroup
      when 'Repository'
        Repository
      else
        raise RuntimeError, "Unrecognized assessable type #{assessable_type_name}"
    end
  end

  def allowed_params
    params[:assessment].permit(:assessable_id, :date, :notes, :preservation_risks, :assessable_type, :name,
                               :preservation_risk_level, :assessment_type, :naming_conventions, :storage_medium_id,
                               :directory_structure, :last_access_date, :file_format, :total_file_size, :total_files, :author_email)
  end

end
