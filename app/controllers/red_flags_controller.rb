class RedFlagsController < ApplicationController

  before_filter :find_red_flag, :only => [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
  end

  protected

  def find_red_flag
    @red_flag = RedFlag.find(params[:id])
  end

end
