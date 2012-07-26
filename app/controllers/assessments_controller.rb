class AssessmentsController < ApplicationController

  before_filter :find_assessment_and_collection, :only => [:destroy, :show, :edit, :update]

  def destroy
    @assessment.destroy
    redirect_to collection_path(@collection)
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
    @collection = Collection.find(params[:collection_id])
    @assessment = Assessment.new
    @assessment.collection = @collection
  end

  def create
    @collection = Collection.find(params[:assessment].delete(:collection_id))
    @assessment = Assessment.new(params[:assessment])
    @assessment.collection = @collection
    if @assessment.save
      redirect_to assessment_path(@assessment)
    else
      render 'new'
    end
  end

  protected

  def find_assessment_and_collection
    @assessment = Assessment.find(params[:id])
    @collection = @assessment.collection
  end


end
