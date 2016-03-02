class RedFlagsController < ApplicationController

  before_action :require_medusa_user
  before_action :find_red_flag, only: [:show, :edit, :update, :unflag]

  def show
  end

  def edit
    authorize! :update, @red_flag
  end

  def update
    authorize! :update, @red_flag
    if @red_flag.update_attributes(allowed_params)
      redirect_to red_flag_path(@red_flag)
    else
      render 'edit'
    end
  end

  def unflag
    authorize! :update, @red_flag
    @red_flag.unflag!
    if request.xhr?
      respond_to {|format| format.js}
    else
      redirect_to :back
    end

  end

  protected

  def find_red_flag
    @red_flag = RedFlag.find(params[:id])
  end

  def allowed_params
    params[:red_flag].permit(:message, :red_flaggable_id, :red_flaggable_type, :notes, :priority, :status)
  end

end
