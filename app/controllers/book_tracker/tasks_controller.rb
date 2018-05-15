module BookTracker

  class TasksController < ApplicationController

    TEMP_DIR = Rails.root.join('public', 'system', 'book_tracker')

    before_action :require_book_tracker_admin
    before_action :service_check_in_progress, except: :index

    ##
    # Responds to POST /book_tracker/check-google
    #
    def check_google
      uploaded_io = params[:file]
      if uploaded_io.respond_to?(:original_filename)
        FileUtils.makedirs(TEMP_DIR)
        pathname = File.join(TEMP_DIR, "google_books_#{SecureRandom.uuid}.txt")

        File.open(pathname, 'wb') do |file|
          file.write(uploaded_io.read)
        end

        Delayed::Job.enqueue(GoogleJob.new(pathname))
        flash['success'] = 'Google check will begin momentarily.'
      else
        flash['error'] = 'No file provided.'
      end
      redirect_back fallback_location: book_tracker_tasks_path
    end

    ##
    # Responds to POST /book_tracker/check-hathitrust
    #
    def check_hathitrust
      Delayed::Job.enqueue(HathitrustJob.new)
      flash['success'] = 'HathiTrust check will begin momentarily.'
      redirect_back fallback_location: book_tracker_tasks_path
    end

    ##
    # Responds to POST /book_tracker/check-internet-archive
    #
    def check_internet_archive
      Delayed::Job.enqueue(InternetArchiveJob.new)
      flash['success'] = 'Internet Archive check will begin momentarily.'
      redirect_back fallback_location: book_tracker_tasks_path
    end

    ##
    # Responds to POST /book_tracker/import
    #
    def import
      Delayed::Job.enqueue(ImportJob.new)
      flash['success'] = 'Import will begin momentarily.'
      redirect_back fallback_location: book_tracker_tasks_path
    end

    ##
    # Responds to GET /book_tracker/tasks
    #
    def index
      @tasks = Task.order(created_at: :desc).limit(100)

      @last_fs_import = Task.where(service: Service::LOCAL_STORAGE).
          where('completed_at IS NOT NULL').
          order(completed_at: :desc).limit(1).first
      @last_ht_check = Task.where(service: Service::HATHITRUST).
          where('completed_at IS NOT NULL').
          order(completed_at: :desc).limit(1).first
      @last_ia_check = Task.where(service: Service::INTERNET_ARCHIVE).
          where('completed_at IS NOT NULL').
          order(completed_at: :desc).limit(1).first
      @last_gb_check = Task.where(service: Service::GOOGLE).
          where('completed_at IS NOT NULL').
          order(completed_at: :desc).limit(1).first

      render partial: 'tasks' if request.xhr?
    end

    private

    def require_book_tracker_admin
      authorize! :update, BookTracker::Item
    end

    def service_check_in_progress
      if Service::check_in_progress?
        flash['error'] = 'Cannot import or check multiple services concurrently.'
        redirect_back fallback_location: book_tracker_tasks_path
      end
    end

  end

end
