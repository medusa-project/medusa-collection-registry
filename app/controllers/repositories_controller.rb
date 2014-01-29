class RepositoriesController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_repository, :only => [:show, :edit, :update, :destroy, :red_flags, :update_ldap_admin]

  def new
    authorize! :create, Repository
    @repository = Repository.new
  end

  def create
    authorize! :create, Repository
    @repository = Repository.new(allowed_params)
    if @repository.save
      redirect_to repository_path(@repository), notice: 'Repository was successfully created.'
    else
      render 'new'
    end
  end

  def show
    @assessable = @repository
    @assessments = @assessable.recursive_assessments
  end

  def index
    @repositories = Repository.all
  end

  def edit
    authorize! :update, @repository
  end

  def update
    authorize! :update, @repository
    if @repository.update_attributes(allowed_params)
      redirect_to repository_path(@repository), notice: 'Repository was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @repository
    @repository.destroy
    redirect_to repositories_path
  end

  def red_flags
    @red_flags = @repository.all_red_flags
    @aggregator = @repository
    render 'shared/red_flags'
  end

  def events
    @scheduled_eventable = @eventable = Repository.find(params[:id])
    @events = @eventable.all_events.sort_by(&:date).reverse
    @scheduled_events = @scheduled_eventable.all_scheduled_events.sort_by(&:action_date)
  end

  def edit_ldap_admins
    authorize! :update_ldap_admins, Repository
  end

  def update_ldap_admin
    authorize! :update_ldap_admins, Repository
    @success = @repository.update_attributes(params[:repository].permit(:ldap_admin_domain, :ldap_admin_group))
    if request.xhr?
      respond_to { |format| format.js }
    else
      flash[:notice] = @success ? 'Update succeeded' : 'Update failed'
        redirect_to edit_ldap_admins_repositories_path
    end
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
  end

  def allowed_params
    params[:repository].permit(:notes, :title, :url, :address_1, :address_2, :city, :state,
                               :zip, :phone_number, :email, :active_start_date,
                               :active_end_date, :contact_net_id)
  end

end
