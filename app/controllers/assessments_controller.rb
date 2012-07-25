class AssessmentsController < ApplicationController

  def destroy
    @assessment = Assessment.find(params[:id])
    collection = @assessment.collection
    @assessment.destroy
    redirect_to collection_path(collection)
  end

  def show
    @assessment = Assessment.find(params[:id])
    @collection = @assessment.collection
  end

  def edit
    @assessment = Assessment.find(params[:id])
    @collection = @assessment.collection
  end

  def update
    @assessment = Assessment.find(params[:id])
    @collection = @assessment.collection
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


end
