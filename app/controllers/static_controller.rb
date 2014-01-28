class StaticController < ApplicationController

  def page
    @partial = params[:page]
  end

end