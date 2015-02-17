class StaticPagesController < ApplicationController

  before_action :find_static_page

  def show
    @form_partial_name = "form_#{@static_page.key}"
    @render_form = template_exists?(@form_partial_name, _prefixes, true)
  end

  def deposit_files
    flash[:notice] = 'Your file deposit request has been submitted.'
    @deposit_files = StaticPageEmail::DepositFiles.new(params[:deposit_files])
    if @deposit_files.valid?
      @deposit_files.send_emails
      redirect_to root_path
    else
      @form_partial_name = 'form_deposit_files'
      @render_form = true
      render 'show'
    end
  end

  def feedback
    flash[:notice] = 'Your feedback has been submitted.'
    @feedback = StaticPageEmail::Feedback.new(params[:feedback])
    if @feedback.valid?
      @feedback.send_emails
      redirect_to root_path
    else
      @form_partial_name = 'form_feedback'
      @render_form = true
      render 'show'
    end
  end

  def request_training
    flash[:notice] = 'Your training request has been submitted'
    @request_training = StaticPageEmail::RequestTraining.new(params[:request_training])
    if @request_training.valid?
      @request_training.send_emails
      redirect_to root_path
    else
      @form_partial_name = 'form_request_training'
      @render_form = true
      render 'show'
    end
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