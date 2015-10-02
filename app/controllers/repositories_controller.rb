class RepositoriesController < ApplicationController

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
    setup_file_stats
    setup_full_storage_summary
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
    @amazon_info = amazon_info
  end

  #return a hash with key the id
  #values are hashes with title, collection id and title, repository id and title, total file size and count,
  #last backup date (or nil) and last backup completed (or nil)
  def amazon_info
    backup_info_hash = file_group_latest_amazon_backup_hash
    file_group_info_query = <<SQL
    SELECT FG.id, FG.title, FG.total_files, FG.total_file_size, C.id AS collection_id, C.title AS collection_title,
           R.id AS repository_id, R.title AS repository_title
    FROM file_groups FG, collections C, repositories R, cfs_directories CFS
    WHERE FG.type = 'BitLevelFileGroup' AND FG.collection_id = C.id AND c.repository_id = R.id
    AND R.id = #{@repository.id}
    AND CFS.parent_type = 'FileGroup' AND CFS.parent_id = FG.id
    ORDER BY FG.id ASC
SQL
    file_groups = FileGroup.connection.select_all(file_group_info_query)
    file_groups = file_groups.to_hash
    file_groups = file_groups.collect { |h| h.with_indifferent_access }
    Hash.new.tap do |hash|
      file_groups.each do |file_group|
        id = file_group[:id].to_i
        hash[id] = file_group
        if backup_info = backup_info_hash[id]
          file_group[:backup_date] = backup_info[:date]
          file_group[:backup_completed] = backup_info[:completed] ? 'Yes' : 'No'
        else
          file_group[:backup_date] = 'None'
          file_group[:backup_completed] = 'N/A'
        end
      end
    end
  end

  #hash from file_group_id to hash with latest backup date and whether it is complete, as judged from the part_count
  #and archive_ids
  def file_group_latest_amazon_backup_hash
    query = <<SQL
    SELECT FG.id AS file_group_id, AB.part_count, AB.archive_ids, AB.date FROM amazon_backups AB,
    (SELECT cfs_directory_id, MAX(date) AS max_date FROM amazon_backups GROUP BY cfs_directory_id) ABLU,
    cfs_directories CFS, file_groups FG
    WHERE AB.cfs_directory_id = ABLU.cfs_directory_id AND AB.date = ABLU.max_date AND AB.part_count IS NOT NULL
    AND AB.archive_ids IS NOT NULL AND CFS.id = AB.cfs_directory_id
    AND FG.id = CFS.parent_id AND CFS.parent_type = 'FileGroup'
SQL
    backups = FileGroup.connection.select_rows(query)
    Hash.new.tap do |hash|
      backups.each do |file_group_id, part_count, archive_ids, date|
        hash[file_group_id.to_i] = HashWithIndifferentAccess.new.tap do |backup_hash|
          backup_hash[:date] = date
          archives = YAML.load(archive_ids)
          backup_hash[:completed] = (archives.present? && (archives.size == part_count.to_i) && archives.none? { |id| id.blank? })
        end
      end
    end
  end

  def setup_red_flags
    @red_flags = @repository.all_red_flags
    @aggregator = @repository
  end

  def setup_file_stats
    # @content_type_hashes = ContentType.connection.select_all('SELECT id, name, cfs_file_count, cfs_file_size FROM content_types ORDER BY name ASC').to_hash
    # @file_extension_hashes = FileExtension.connection.select_all('SELECT id, extension, cfs_file_count, cfs_file_size FROM file_extensions ORDER BY extension ASC').to_hash
  end

  def setup_full_storage_summary
  #   @full_storage_summary = Hash.new.tap do |h|
  #     FileGroup.group(:type).select('type, sum(total_file_size) as size, sum(total_files) as count').each do |row|
  #       h[row[:type]] = {count: row[:count], size: row[:size]}
  #     end
  #   end
  #   %w(ExternalFileGroup BitLevelFileGroup).each do |type|
  #     @full_storage_summary[type] ||= {count: 0, size: 0}
  #   end
  end

end
