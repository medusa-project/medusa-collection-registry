class StaticController < ApplicationController

  skip_before_filter :require_logged_in
  skip_before_filter :authorize

  def page
    @partial = params[:page]
  end

end