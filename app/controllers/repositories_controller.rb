class RepositoriesController < ApplicationController
  include DashboardCommon

  before_action :require_logged_in
  before_action :find_repository, only: [:edit, :update, :destroy, :red_flags, :update_ldap_admin, :collections, :events, :assessments]
  include ModelsToCsv

  def new
    authorize! :create, Repository
    @repository = Repository.new
    @institution_id = params[:institution_id]
  end

  def create
    authorize! :create, Repository
    #TODO check that the user is allowed to create with the supplied institution
    @repository = Repository.new(allowed_params)
    if @repository.save
      redirect_to repository_path(@repository), notice: 'Repository was successfully created.'
    else
      render 'new'
    end
  end

  def show
    @repository = Repository.includes(collections: [:assessments, :contact, :preservation_priority,
                                                    {file_groups: [:cfs_directory, :assessments]}]).find(params[:id])
    setup_events
    setup_amazon_info
    setup_red_flags
    setup_file_stats_and_full_storage_summary
    setup_accrual_jobs
  end

  def assessments
    @assessable = @repository
    @assessments = @assessable.recursive_assessments
  end

  def index
    @repositories = Repository.all.includes(collections: {file_groups: :cfs_directory}).includes(:contact)
    respond_to do |format|
      format.html
      format.csv { send_data repositories_to_csv(@repositories), type: 'text/csv', filename: 'repositories.csv' }
    end
  end

  def edit
    authorize! :update, @repository
  end

  def update
    authorize! :update, @repository
    #disallow changing the owning institution
    params[:repository].delete(:institution_id)
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
    setup_red_flags
  end

  def events
    @scheduled_eventable = @eventable = Repository.find(params[:id])
    @events = @eventable.cascaded_events
    @scheduled_events = @scheduled_eventable.incomplete_scheduled_events.sort_by(&:action_date)
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

  def collections
    respond_to do |format|
      format.csv { send_data collections_to_csv(@repository.collections), type: 'text/csv', filename: 'collections.csv' }
    end
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
    @breadcrumbable = @repository
  end

  def allowed_params
    params[:repository].permit(:notes, :title, :url, :address_1, :address_2, :city, :state,
                               :zip, :phone_number, :email, :active_start_date,
                               :active_end_date, :contact_email, :institution_id)
  end

  def setup_events
    @events = @repository.cascaded_events.where('events.updated_at > ?', Time.now - 7.days).where(cascadable: true).includes(eventable: :parent)
    @scheduled_events = @repository.incomplete_scheduled_events
  end

  def setup_amazon_info
    file_groups = FileGroup.connection.select_all('SELECT * FROM view_file_group_dashboard_info WHERE repository_id = $1', nil, [[nil, @repository.id]]).to_hash.collect {|h| h.with_indifferent_access}
    backups = FileGroup.connection.select_rows('SELECT * FROM view_file_groups_latest_amazon_backup V WHERE repository_id = $1', nil, [[nil, @repository.id]])
    @amazon_info = amazon_info(file_groups, backups)
  end

  def setup_red_flags
    @red_flags = @repository.all_red_flags
    @aggregator = @repository
  end

  def setup_file_stats_and_full_storage_summary
    @file_extension_hashes = ActiveRecord::Base.connection.
        select_all('SELECT file_extension_id, extension, file_size, file_count FROM view_file_extension_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]]).to_hash
    @content_type_hashes = ActiveRecord::Base.connection.
        select_all('SELECT content_type_id, name, file_size, file_count FROM view_file_content_type_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]])
    @bit_level_storage_summary = ActiveRecord::Base.connection.
        select_all('SELECT COALESCE(SUM(COALESCE(F.size,0)), 0) AS size, COUNT(*) AS count FROM view_cfs_files_to_parents V JOIN cfs_files F ON V.cfs_file_id = F.id WHERE V.repository_id = $1', nil, [[nil, @repository.id]]).to_hash.first
  end

  def setup_accrual_jobs
    if ApplicationController.is_ad_admin?(current_user)
      accrual_jobs = Workflow::AccrualJob.order('created_at asc').all.decorate
    else
      accrual_jobs = current_user.workflow_accrual_jobs.order('created_at asc').decorate
    end
    @accrual_jobs = accrual_jobs.select {|accrual_job| accrual_job.repository == @repository}
  end

end
