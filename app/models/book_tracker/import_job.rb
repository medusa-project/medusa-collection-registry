require 'nokogiri'

module BookTracker

  ##
  # DelayedJob that recursively scans a given directory for MARCXML records to
  # import, and imports them.
  #
  class ImportJob < Struct.new(:a)

    QUEUE_NAME = 'book_tracker:import'

    def self.import_in_progress?
      Task.where(service: Service::LOCAL_STORAGE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    ##
    # For delayed_job
    #
    def max_attempts
      1
    end

    ##
    # For delayed_job
    #
    def queue_name
      QUEUE_NAME
    end

    ##
    # Imports records from a tree of MARCXML files, updating them if one with
    # the same bib ID already exists, and adding them if not.
    #
    def perform
      if ImportJob.import_in_progress? or Service.check_in_progress?
        raise 'Cannot import while another import or service check is in '\
        'progress.'
      end

      task = Task.create!(name: 'Importing MARCXML records',
                          service: Service::LOCAL_STORAGE)
      puts task.name

      begin
        path = MedusaRails3::Application.medusa_config['book_tracker']['import_path']
        raise "Import path (#{path}) does not exist." unless Dir.exist?(path)

        num_inserted = 0
        num_updated = 0

        # Find all XML files in or beneath self.path
        files = Dir.glob(File.expand_path(path.chomp('/')) + '/**/*.xml').
            select{ |file| File.file?(file) }
        files.each_with_index do |file, index|
          File.open(file) do |contents|
            doc = Nokogiri::XML(contents, &:noblanks)
            doc.encoding = 'utf-8'

            doc.xpath('//xmlns:collection/xmlns:record').each do |record|
              item, status = Item.insert_or_update!(
                  Item.params_from_marcxml_record(record))
              if status == Item::INSERTED
                num_inserted += 1
              else
                num_updated += 1
              end
            end
          end
          task.percent_complete = (index + 1).to_f / files.length.to_f
          task.save!
        end
      rescue => e
        task.name = "Import failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
      else
        task.name += ": #{num_inserted} records inserted; #{num_updated} "\
        "records updated or unchanged in #{files.length} files"
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

    ##
    # delayed_job hook
    #
    def error(job, exception)
      task = current_task
      task.name = "Import failed: #{exception}"
      task.status = Status::FAILED
      task.save!
    end

    ##
    # delayed_job hook
    #
    def failure(job)
      self.error(job, 'Unknown Delayed::Job failure')
    end

    private

    def current_task
      Task.where(service: Service::LOCAL_STORAGE).order(created_at: :desc).first
    end

  end

end
