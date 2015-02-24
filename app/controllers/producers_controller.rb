class ProducersController < ApplicationController

  before_action :require_logged_in
  before_action :find_producer, only: [:show, :destroy, :edit, :update]

  def index
    @producers = Producer.all
  end

  def show

  end

  def destroy
    authorize! :destroy, @producer
    if @producer.destroy
      redirect_to producers_path
    else
      redirect_to :back, alert: 'Producers with associated file groups cannot be deleted.'
    end
  end

  def new
    authorize! :create, Producer
    @producer = Producer.new
  end

  def create
    authorize! :create, Producer
    @producer = Producer.new(allowed_params)
    if @producer.save
      redirect_to producer_path(@producer)
    else
      render 'new'
    end
  end

  def edit
    authorize! :update, Producer
  end

  def update
    authorize! :update, Producer
    if @producer.update_attributes(allowed_params)
      redirect_to @producer
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
                             :phone_number, :state, :title, :url, :zip,
                             :active_start_date, :active_end_date, :administrator_email)
  end
end
