class StaticPagesController < ApplicationController

  before_action :find_static_page

  def show
    @form_partial_name = "form_#{@static_page.key}"
    @render_form = template_exists?(@form_partial_name, _prefixes, true)
  end

  def deposit_files
    flash[:notice] = 'Your file deposit request has been submitted.'
    redirect_to :back
  end

  def feedback
    flash[:notice] = 'Your feedback has been submitted.'
    redirect_to :back
  end

  def request_training
    flash[:notice] = 'Your training request has been submitted'
    redirect_to :back
  end

  def edit
    authorize! :update, @static_page
  end

  def update
    authorize! :update, @static_page
    if @static_page.update_attributes(params[:static_page].permit(:page_text))
      redirect_to static_page_path(key: @static_page.key)
    else
      render 'edit'
    end
  end

  protected

  def find_static_page
    @static_page = StaticPage.find_by(key: params[:key])
  end

end