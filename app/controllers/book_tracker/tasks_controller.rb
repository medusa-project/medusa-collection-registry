module BookTracker

  class TasksController < ApplicationController

    before_filter :require_book_tracker_admin

    ##
    # Responds to POST /check-hathitrust
    #
    def check_hathitrust
      if ImportJob.import_in_progress?
        flash[:error] = 'Cannot check HathiTrust while an import is in progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'A service check is already in progress.'
      else
        Delayed::Job.enqueue(HathitrustJob.new)
        flash[:success] = 'HathiTrust check will begin momentarily.'
      end
      redirect_to :back
    end

    ##
    # Responds to POST /check-internet-archive
    #
    def check_internet_archive
      if ImportJob.import_in_progress?
        flash[:error] = 'Cannot check Internet Archive while an import is in '\
        'progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'A service check is already in progress.'
      else
        Delayed::Job.enqueue(InternetArchiveJob.new)
        flash[:success] = 'Internet Archive check will begin momentarily.'
      end
      redirect_to :back
    end

    ##
    # Responds to POST /import
    #
    def import
      if ImportJob.import_in_progress?
        flash[:error] = 'An import is already in progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'Cannot import while a service check is in progress.'
      else
        Delayed::Job.enqueue(ImportJob.new)
        flash[:success] = 'Import will begin momentarily.'
      end
      redirect_to :back
    end

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

  end

end
