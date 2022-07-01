class VirtualRepositoriesController < ApplicationController
  include ModelsToCsv

  before_action :require_medusa_user, except: :index
  before_action :require_medusa_user_or_basic_auth, only: :index
  before_action :find_virtual_repository, only: [:edit, :update, :destroy, :show, :show_file_stats]
  helper_method :load_virtual_repository_file_extension_stats, :load_virtual_repository_content_type_stats

  def index

  end

  def show

  end

  def show_file_stats
    respond_to do |format|
      format.html {render partial: 'file_stats_table', layout: false}
      format.csv do
        content_type_hashes = load_virtual_repository_content_type_stats(@virtual_repository)
        file_extension_hashes = load_virtual_repository_file_extension_stats(@virtual_repository)
        send_data file_stats_to_csv(content_type_hashes, file_extension_hashes), type: 'text/csv', filename: 'file-statistics.csv'
      end
    end
  end

  def new
    @virtual_repository = VirtualRepository.new
    @repository = Repository.find(params[:repository_id])
    @virtual_repository.repository = @repository
    authorize! :update, @repository
  end

  def create
    @repository = Repository.find(params[:virtual_repository][:repository_id])
    authorize! :update, @repository
    collection_ids = params[:virtual_repository].delete(:collection_ids)
    @virtual_repository = VirtualRepository.new(allowed_params)
    begin
      if @virtual_repository.save
        @virtual_repository.collection_ids = collection_ids
        redirect_to @virtual_repository
      else
        render 'new'
      end
    rescue
      render 'new'
    end
  end

  def edit
    authorize! :update, @virtual_repository.repository
  end

  def update
    authorize! :update, @virtual_repository.repository
    params[:virtual_repository].delete(:repository_id) if params[:virtual_repository][:repository_id].present?
    if @virtual_repository.update_attributes(allowed_params)
      redirect_to @virtual_repository
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :update, @virtual_repository.repository
    if @virtual_repository.destroy
      redirect_to @virtual_repository.repository
    else
      raise RuntimeError, 'Unable to destroy virtual repository'
    end
  end

  protected

  def find_virtual_repository
    @virtual_repository = VirtualRepository.find(params[:id])
    @breadcrumbable = @virtual_repository
  end

  def allowed_params
    params[:virtual_repository].permit(:title, :repository_id, collection_ids: [])
  end

  def load_virtual_repository_content_type_stats(virtual_repository)
    ActiveRecord::Base.connection.
        select_all(load_virtual_repository_dashboard_content_type_sql(virtual_repository.collection_ids))
  end

  def load_virtual_repository_file_extension_stats(virtual_repository)
    ActiveRecord::Base.connection.
        select_all(load_virtual_repository_dashboard_file_extension_sql(virtual_repository.collection_ids)).to_unsafe_h
  end

  def load_virtual_repository_dashboard_content_type_sql(collection_ids)
    id_string = "(#{collection_ids.join(',')})"
    <<SQL
SELECT STATS.content_type_id, STATS.name, STATS.file_size, STATS.file_count, COALESCE(TESTED.count, 0) AS tested_count
FROM
  (SELECT content_type_id, name, SUM(file_size) AS file_size,
      SUM(file_count) AS file_count
   FROM cache_content_type_stats_by_collection
   WHERE collection_id IN #{id_string}
   GROUP BY content_type_id, name) STATS
LEFT JOIN
  (SELECT content_type_id, SUM(COALESCE(count,0)) AS count
   FROM view_tested_file_content_type_counts_by_collection
   WHERE collection_id IN #{id_string}
   GROUP BY content_type_id) TESTED
ON STATS.content_type_id = TESTED.content_type_id
WHERE STATS.file_count > 0
SQL
  end

  def load_virtual_repository_dashboard_file_extension_sql(collection_ids)
    id_string = "(#{collection_ids.join(',')})"
    <<SQL
SELECT STATS.file_extension_id, STATS.extension, STATS.file_size, STATS.file_count, COALESCE(TESTED.count, 0) AS tested_count
FROM
  (SELECT file_extension_id, extension, SUM(file_size) AS file_size,
      SUM(file_count) AS file_count
   FROM cache_file_extension_stats_by_collection
   WHERE collection_id IN #{id_string}
   GROUP BY file_extension_id, extension) STATS
LEFT JOIN
  (SELECT file_extension_id, SUM(COALESCE(count, 0)) AS count
   FROM view_tested_file_file_extension_counts_by_collection
   WHERE collection_id in #{id_string}
   GROUP BY file_extension_id) TESTED
ON STATS.file_extension_id = TESTED.file_extension_id
WHERE STATS.file_count > 0
SQL
  end

end