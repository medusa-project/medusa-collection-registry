class ProducersController < ApplicationController

  before_filter :find_producer, :only => [:show, :destroy, :edit, :update]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def index
    @producers = Producer.all
  end

  def show

  end

  def destroy
    if @producer.destroy
      redirect_to producers_path
    else
      redirect_to :back, :alert => 'Producers with associated file groups cannot be deleted.'
    end
  end

  def new
    @producer = Producer.new
  end

  def create
    @producer = Producer.new(allowed_params)
    if @producer.save
      redirect_to producer_path(@producer)
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @producer.update_attributes(allowed_params)
      redirect_to producer_path(@producer)
    else
      render 'edit'
    end

  end

  protected

  def find_producer
    @producer = Producer.find(params[:id])
  end

  def allowed_params
    params[:producer].permit(:address_1, :address_2, :city, :email, :notes,
                             :phone_number, :state, :title, :url, :zip, :active_start_date, :active_end_date)
  end
end
