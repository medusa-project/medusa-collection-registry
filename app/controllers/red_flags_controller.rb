class RedFlagsController < ApplicationController

  before_filter :find_red_flag, :only => [:show, :edit, :update, :unflag]

  def show
  end

  def edit
  end

  def update
    if @red_flag.update_attributes(params[:red_flag])
      redirect_to red_flag_path(@red_flag)
    else
      render 'edit'
    end
  end

  def unflag
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

end
