class AssessmentsController < ApplicationController

  before_filter :find_assessment_and_assessable, :only => [:destroy, :show, :edit, :update]
  helper :assessments

  def destroy
    @assessment.destroy
    redirect_to @assessable
  end

  def show

  end

  def edit

  end

  def update
    if @assessment.update_attributes(params[:assessment])
      redirect_to assessment_path(@assessment)
    else
      render 'edit'
    end
  end

  def new
    klass = assessable_class(params)
    @assessable = klass.find(params[:assessable_id])
    @assessment = Assessment.new
    @assessment.author = Person.find_or_create_by_net_id(current_user.uid)
    @assessment.assessable = @assessable
  end

  def create
    klass = assessable_class(params[:assessment])
    @assessable = klass.find(params[:assessment].delete(:assessable_id))
    @assessment = @assessable.build(params[:assessment])
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
      when 'FileGroup', 'ExternalFileGroup', 'BitLevelFileGroup', 'ObjectLevelFileGroup'
        FileGroup
      else
        raise RuntimeError, 'Unrecognized assessable type'
    end
  end

end
