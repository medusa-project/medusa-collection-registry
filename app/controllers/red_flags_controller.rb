class RedFlagsController < ApplicationController

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
      redirect_back fallback_location: @red_flag.red_flagabble
    end

  end

  def mass_unflag
    authorize! :unflag, RedFlag
    @red_flags = RedFlag.find(params[:mass_unflag])
    @red_flags.each {|rf| rf.unflag!}
    respond_to do |format|
      format.js
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
