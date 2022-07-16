class ProducersController < ApplicationController

  before_action :require_medusa_user
  before_action :find_producer, only: [:destroy, :edit, :update, :report]

  def index
    @producers = Producer.includes(:administrator).all
  end

  def show
    @producer = Producer.includes(file_groups: {collection: [:contact, :repository, :bit_level_file_groups]}).find(params[:id])
  end

  def destroy
    authorize! :destroy, @producer
    if @producer.destroy
      redirect_to producers_path
    else
      redirect_back(fallback_location: root_path, alert: 'Producers with associated file groups cannot be deleted.')
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
    if @producer.update(allowed_params)
      redirect_to @producer
    else
      render 'edit'
    end

  end

  def report
    Job::Report::Producer.create_for(user: current_user, producer: @producer)
    respond_to do |format|
      format.js
      format.html do
        redirect_to @producer, notice: 'Your report will be emailed to you shortly.'
      end
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
