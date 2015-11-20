class RepositoriesController < ApplicationController
  include DashboardCommon

  before_action :require_logged_in
  before_action :find_repository, only: [:edit, :update, :destroy, :red_flags, :update_ldap_admin,
                                         :collections, :events, :assessments,
                                         :show_file_stats, :show_running_processes, :show_red_flags, :show_events,
                                         :show_amazon, :show_accruals]
  include ModelsToCsv

  helper_method :load_file_extension_stats, :load_content_type_stats

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
    @repository = Repository.includes(collections: [:assessments, :contact, :preservation_priority, :bit_level_file_groups,
                                                    {file_groups: [:cfs_directory, :assessments]}]).find(params[:id])
  end

  def show_file_stats
    respond_to do |format|
      format.html {render partial: 'file_stats_table', layout: false}
      format.csv do
        content_type_hashes = load_content_type_stats(@repository)
        file_extension_hashes = load_file_extension_stats(@repository)
        send_data file_stats_to_csv(content_type_hashes, file_extension_hashes), type: 'text/csv', filename: 'file-statistics.csv'
      end
    end

  end

  def show_running_processes
    render partial: 'running_processes', layout: false
  end

  def show_red_flags
    setup_red_flags
    render partial: 'shared/red_flags_table', layout: false
  end

  def show_events
    render partial: 'events', layout: false
  end

  def show_amazon
    file_groups = FileGroup.connection.select_all('SELECT * FROM view_file_group_dashboard_info WHERE repository_id = $1', nil, [[nil, @repository.id]]).to_hash.collect { |h| h.with_indifferent_access }
    backups = FileGroup.connection.select_rows('SELECT * FROM view_file_groups_latest_amazon_backup V WHERE repository_id = $1', nil, [[nil, @repository.id]])
    @amazon_info = amazon_info(file_groups, backups)
    render partial: 'amazon', layout: false
  end

  def show_accruals
    if ApplicationController.is_ad_admin?(current_user)
      accrual_jobs = Workflow::AccrualJob.order('created_at asc').all.decorate
    else
      accrual_jobs = current_user.workflow_accrual_jobs.order('created_at asc').decorate
    end
    @accrual_jobs = accrual_jobs.select { |accrual_job| accrual_job.repository == @repository }
    render partial: 'accruals/accruals', layout: false
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
    @eventable = Repository.find(params[:id])
    @events = @eventable.cascaded_events
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

  def setup_red_flags
    @red_flags = @repository.cascaded_red_flags
    @aggregator = @repository
  end

  def load_content_type_stats(repository)
    ActiveRecord::Base.connection.
        select_all(load_repository_dashboard_content_type_sql, nil, [[nil, repository.id]])
  end

  def load_file_extension_stats(repository)
    ActiveRecord::Base.connection.
        select_all(load_repository_dashboard_file_extension_sql, nil, [[nil, repository.id]]).to_hash
  end

  def load_repository_dashboard_content_type_sql
    <<SQL
    SELECT CTS.content_type_id, CTS.name, CTS.file_size, CTS.file_count,
    COALESCE(CTC.count,0) AS tested_count
    FROM view_file_content_type_stats_by_repository CTS
    LEFT JOIN (SELECT content_type_id, count FROM view_tested_file_content_type_counts WHERE repository_id = $1) CTC
    ON CTS.content_type_id = CTC.content_type_id
    WHERE repository_id = $1
SQL
  end

  def load_repository_dashboard_file_extension_sql
    <<SQL
    SELECT FES.file_extension_id, FES.extension, FES.file_size, FES.file_count,
    COALESCE(FEC.count,0) AS tested_count
    FROM view_file_extension_stats_by_repository FES
    LEFT JOIN (SELECT file_extension_id, count FROM view_tested_file_file_extension_counts WHERE repository_id = $1) FEC
    ON FES.file_extension_id = FEC.file_extension_id
    WHERE repository_id = $1
SQL
  end

end
