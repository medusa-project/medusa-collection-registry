class ProducersController < ApplicationController

  before_filter :find_producer, :only => [:show, :destroy, :edit, :update]

  def index
    @producers = Producer.all
  end

  def show

  end

  def destroy
    if @producer.destroy
      redirect_to producers_path
    else
      redirect_to :back, :alert=> 'Producers with associated file groups cannot be deleted.'
    end
  end

  def new
    @producer = Producer.new
  end

  def create
    @producer = Producer.new(params[:producer])
    if @producer.save
      redirect_to producer_path(@producer)
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @producer.update_attributes(params[:producer])
      redirect_to producer_path(@producer)
    else
      render 'edit'
    end

  end

  protected

  def find_producer
    @producer = Producer.find(params[:id])
  end
end
