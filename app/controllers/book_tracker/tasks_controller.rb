module BookTracker

  class TasksController < ApplicationController

    before_filter :require_book_tracker_admin

    ##
    # Responds to POST /check-hathitrust
    #
    def check_hathitrust
      if Filesystem.import_in_progress?
        flash[:error] = 'Cannot check HathiTrust while an import is in progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'A service check is already in progress.'
      else
        pid = Process.spawn('rake', 'book_tracker:check_hathitrust',
                            out: '/dev/null', err: '/dev/null')
        Process.detach(pid)

        flash[:success] = 'Checking HathiTrust.'
      end
      redirect_to :back
    end

    ##
    # Responds to POST /check-internet-archive
    #
    def check_internet_archive
      if Filesystem.import_in_progress?
        flash[:error] = 'Cannot check Internet Archive while an import is in '\
        'progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'A service check is already in progress.'
      else
        pid = Process.spawn('rake', 'book_tracker:check_internet_archive',
                            out: '/dev/null', err: '/dev/null')
        Process.detach(pid)

        flash[:success] = 'Checking Internet Archive.'
      end
      redirect_to :back
    end

    ##
    # Responds to POST /import
    #
    def import
      if Filesystem.import_in_progress?
        flash[:error] = 'An import is already in progress.'
      elsif Service.check_in_progress?
        flash[:error] = 'Cannot import while a service check is in progress.'
      else
        pid = Process.spawn('rake', 'book_tracker:import',
                            out: '/dev/null', err: '/dev/null')
        Process.detach(pid)

        flash[:success] = 'Importing MARCXML files.'
      end
      redirect_to :back
    end

    def index
      @tasks = Task.order(created_at: :desc).limit(100)

      @last_fs_import = Task.where('name LIKE \'Import%\'').
          order(completed_at: :desc).limit(1).first
      @last_ht_check = Task.where(service: Service::HATHITRUST).
          order(completed_at: :desc).limit(1).first
      @last_ia_check = Task.where(service: Service::INTERNET_ARCHIVE).
          order(completed_at: :desc).limit(1).first

      render partial: 'tasks' if request.xhr?
    end

    def require_book_tracker_admin
      authorize! :update, BookTracker::Item
    end

  end

end
